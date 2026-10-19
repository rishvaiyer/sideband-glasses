import Foundation

public struct Observation: Identifiable, Codable, Equatable {
    public var id: String
    public var services: [String]
    public var rssi: Int
    public var timestamp: TimeInterval
    public init(id: String, services: [String], rssi: Int, timestamp: TimeInterval) {
        self.id = id; self.services = services; self.rssi = rssi; self.timestamp = timestamp
    }
}
public struct Signal: Identifiable, Codable, Equatable {
    public var id: String
    public var firstSeen: TimeInterval
    public var lastSeen: TimeInterval
    public var samples: [Int]
    public var services: [String]
    public var observations: Int
    public var ignored: Bool
    public var medianRSSI: Int { let sorted = samples.sorted(); return sorted[sorted.count / 2] }
    public var possibleMeta: Bool { services.contains { $0.uppercased() == "FD5F" || $0.uppercased() == "0000FD5F-0000-1000-8000-00805F9B34FB" } }
    public var title: String { possibleMeta ? "Meta-associated signal" : "Unclassified Bluetooth signal" }
    public var evidence: String { possibleMeta ? "Advertises FD5F. This service alone does not identify glasses or prove recording." : "No supported device signature. Device type and recording state are unknown." }
    public func active(at now: TimeInterval) -> Bool { now >= lastSeen && now - lastSeen <= 20 }
    public var alertEligible: Bool { possibleMeta && observations >= 3 && lastSeen - firstSeen >= 2 && !ignored }
}
public struct SignalSession {
    public private(set) var signals: [String: Signal] = [:]
    public private(set) var alerts: [String] = []
    public var quiet = false
    private var announced: Set<String> = []
    private var lastAlert = -Double.infinity
    public init() {}
    public mutating func ingest(_ observation: Observation) -> String? {
        guard observation.timestamp.isFinite, !observation.id.isEmpty, observation.id.count <= 128,
              (-127 ... -1).contains(observation.rssi), observation.services.count <= 64 else { return nil }
        if let existing = signals[observation.id], observation.timestamp < existing.lastSeen { return nil }
        if signals[observation.id] == nil && signals.count >= 128 { return nil }
        var signal = signals[observation.id] ?? Signal(id: observation.id, firstSeen: observation.timestamp, lastSeen: observation.timestamp, samples: [], services: [], observations: 0, ignored: false)
        signal.lastSeen = observation.timestamp
        signal.samples = Array((signal.samples + [observation.rssi]).suffix(20))
        signal.observations += 1
        signal.services = Array(Set(signal.services + observation.services.map { $0.uppercased() }.filter { $0.count <= 36 }).sorted().prefix(64))
        signals[signal.id] = signal
        guard signal.alertEligible, !quiet, !announced.contains(signal.id), observation.timestamp - lastAlert >= 30 else { return nil }
        let message = "A Meta-associated Bluetooth signal has appeared nearby. Device type and recording are unconfirmed."
        announced.insert(signal.id); lastAlert = observation.timestamp; alerts.append(message)
        return message
    }
    public mutating func toggleIgnored(_ id: String) { signals[id]?.ignored.toggle() }
    public func recap(at now: TimeInterval) -> String {
        let active = signals.values.filter { $0.active(at: now) && !$0.ignored }.count
        let matched = signals.values.filter { $0.possibleMeta && !$0.ignored }.count
        return "Session recap. \(signals.count) Bluetooth signals observed. \(active) recently seen. \(matched) matched the Meta-associated service rule. Recording was not determined."
    }
}
