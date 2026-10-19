import Foundation
import Combine
import CoreBluetooth
import AVFoundation
import SidebandCore

final class ListeningModel: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var signals: [Signal] = []
    @Published var running = false
    @Published var demo = true
    @Published var quiet = false { didSet { session.quiet = quiet; if quiet { speech.stopSpeaking(at: .immediate) } } }
    @Published var voice = false { didSet { if !voice { speech.stopSpeaking(at: .immediate) } } }
    @Published var status = "Choose a demo or start a foreground Bluetooth session."
    @Published var audioRoute = "Not checked"
    @Published var hasPrivateOutput = false
    @Published var elapsed = 0
    private var session = SignalSession()
    private var manager: CBCentralManager?
    private var timer: Timer?
    private var startTime = Date()
    private var scanRequested = false
    private var aliases: [UUID: String] = [:]
    private let speech = AVSpeechSynthesizer()
    private var routeObserver: NSObjectProtocol?
    override init() {
        super.init()
        routeObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateRoute()
            if self?.hasPrivateOutput == false { self?.speech.stopSpeaking(at: .immediate) }
        }
        updateRoute()
    }
    deinit { timer?.invalidate(); if let routeObserver { NotificationCenter.default.removeObserver(routeObserver) } }
    func updateRoute() {
        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
        audioRoute = outputs.map(\.portName).joined(separator: ", ")
        hasPrivateOutput = outputs.contains { [.bluetoothA2DP, .bluetoothHFP, .bluetoothLE, .headphones].contains($0.portType) }
    }
    func start() {
        guard !running else { return }
        session = SignalSession(); session.quiet = quiet; aliases = [:]; signals = []; elapsed = 0; startTime = Date()
        scanRequested = !demo
        if demo { begin() }
        else {
            if manager == nil { manager = CBCentralManager(delegate: self, queue: .main) }
            else { beginBluetoothIfReady() }
        }
    }
    private func begin() {
        running = true
        status = demo ? "Demo running. These signals are simulated." : "Listening while Sideband is open. Recording status cannot be determined."
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.tick() }
    }
    private func beginBluetoothIfReady() {
        guard scanRequested, let manager else { return }
        switch manager.state {
        case .poweredOn:
            manager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]); begin()
        case .unauthorized: status = "Bluetooth access is off. Enable it in Settings to listen. Demo remains available."
        case .poweredOff: status = "Bluetooth is off. Turn it on to listen, or use the demo."
        case .unsupported: status = "Bluetooth scanning is unavailable on this device. Demo remains available."
        default: status = "Waiting for Bluetooth availability."
        }
    }
    func stop() {
        scanRequested = false; running = false; elapsed = Int(ceil(Date().timeIntervalSince(startTime))); timer?.invalidate(); timer = nil; manager?.stopScan(); speech.stopSpeaking(at: .immediate)
        status = "Session stopped. Observations stay here until reset."
    }
    func reset() { stop(); session = SignalSession(); session.quiet = quiet; signals = []; aliases = [:]; elapsed = 0; status = "Session cleared." }
    private func tick() {
        elapsed = Int(Date().timeIntervalSince(startTime))
        if demo {
            for i in 0..<3 where elapsed >= i * 5 {
                let rssi = -46 - i * 9 + Int(sin(Double(elapsed) / 3 + Double(i)) * 7)
                ingest(Observation(id: "Signal \(i + 1)", services: i == 1 ? ["180F"] : ["FD5F"], rssi: rssi, timestamp: Double(elapsed)))
            }
        }
        objectWillChange.send()
    }
    private func ingest(_ observation: Observation) {
        if let alert = session.ingest(observation) { status = alert; if voice { speak((demo ? "Demo alert. " : "") + alert) } }
        signals = session.signals.values.sorted { $0.id < $1.id }
    }
    func toggleIgnored(_ id: String) { session.toggleIgnored(id); signals = session.signals.values.sorted { $0.id < $1.id } }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard !demo && scanRequested else { return }
        if central.state != .poweredOn && running { stop(); status = "Bluetooth unavailable. Start a new session when it is ready."; return }
        beginBluetoothIfReady()
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard running && !demo else { return }
        guard aliases[peripheral.identifier] != nil || aliases.count < 128 else { return }
        let id = aliases[peripheral.identifier] ?? "Signal \(aliases.count + 1)"
        aliases[peripheral.identifier] = id
        let services = (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] ?? []).map(\.uuidString)
        ingest(Observation(id: id, services: services, rssi: RSSI.intValue, timestamp: Date().timeIntervalSince(startTime)))
    }
    func speak(_ text: String) {
        do {
            let audio = AVAudioSession.sharedInstance()
            try audio.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try audio.setActive(true)
            updateRoute()
            guard hasPrivateOutput else { status = "Choose your glasses or headphones as audio output before speaking. Sideband will not announce through the phone speaker."; return }
            speech.stopSpeaking(at: .immediate)
            let utterance = AVSpeechUtterance(string: text); utterance.rate = 0.46; speech.speak(utterance)
        } catch { status = "Audio could not start: \(error.localizedDescription)" }
    }
    func testAudio() { speak("Sideband audio check. If you hear this in your glasses, your audio route is working.") }
    var now: Double { running ? Date().timeIntervalSince(startTime) : Double(elapsed) }
    var recap: String { session.recap(at: now) }
    var exportText: String {
        let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        struct Export: Encodable { let schema: String; let source: String; let recordingStatus: String; let durationSeconds: Int; let signals: [Signal]; let recap: String }
        let value = Export(schema: "sideband.session.v1", source: demo ? "simulation" : "iphone-bluetooth", recordingStatus: "unknown", durationSeconds: elapsed, signals: signals, recap: recap)
        return String(data: (try? encoder.encode(value)) ?? Data(), encoding: .utf8) ?? "{}"
    }
}
