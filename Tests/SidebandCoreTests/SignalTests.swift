import XCTest
@testable import SidebandCore
final class SignalTests: XCTestCase {
    func observation(_ time: Double, id: String = "A", rssi: Int = -50, services: [String] = ["FD5F"]) -> Observation { Observation(id: id, services: services, rssi: rssi, timestamp: time) }
    func testRepeatedEvidenceAndOneAlert() { var s = SignalSession(); XCTAssertNil(s.ingest(observation(0))); XCTAssertNil(s.ingest(observation(1))); XCTAssertNotNil(s.ingest(observation(2))); XCTAssertNil(s.ingest(observation(40))); XCTAssertEqual(s.alerts.count, 1) }
    func testIgnored() { var s = SignalSession(); _ = s.ingest(observation(0)); s.toggleIgnored("A"); _ = s.ingest(observation(1)); XCTAssertNil(s.ingest(observation(2))) }
    func testQuiet() { var s = SignalSession(); s.quiet = true; for t in 0..<5 { XCTAssertNil(s.ingest(observation(Double(t)))) }; XCTAssertEqual(s.signals.count, 1) }
    func testInvalidRSSI() { var s = SignalSession(); for rssi in [127, 0, -128] { XCTAssertNil(s.ingest(observation(0, rssi: rssi))) }; XCTAssertTrue(s.signals.isEmpty) }
    func testOutOfOrder() { var s = SignalSession(); _ = s.ingest(observation(9)); _ = s.ingest(observation(2)); XCTAssertEqual(s.signals["A"]?.observations, 1) }
    func testUnknownSignal() { var s = SignalSession(); for t in 0..<5 { _ = s.ingest(observation(Double(t), services: ["180F"])) }; XCTAssertEqual(s.alerts.count, 0) }
    func testCooldown() { var s = SignalSession(); for t in 0..<3 { _ = s.ingest(observation(Double(t))) }; for t in 3..<6 { XCTAssertNil(s.ingest(observation(Double(t), id: "B"))) }; XCTAssertNotNil(s.ingest(observation(33, id: "B"))) }
    func testBoundedMemory() { var s = SignalSession(); for n in 0..<500 { _ = s.ingest(observation(Double(n), id: String(n))) }; XCTAssertEqual(s.signals.count, 128) }
    func testStale() { var s = SignalSession(); _ = s.ingest(observation(0)); XCTAssertEqual(s.signals["A"]?.active(at: 21), false); XCTAssertTrue(s.recap(at: 21).contains("0 recently seen")) }
    func testExpandedServiceUUID() { var s = SignalSession(); _ = s.ingest(observation(0, services: ["0000fd5f-0000-1000-8000-00805f9b34fb"])); XCTAssertEqual(s.signals["A"]?.possibleMeta, true) }
    func testBoundedServiceHistory() { var s = SignalSession(); for n in 0..<200 { _ = s.ingest(observation(Double(n), services: [String(n)])) }; XCTAssertEqual(s.signals["A"]?.services.count, 64) }
}
