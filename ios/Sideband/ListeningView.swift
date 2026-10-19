import SwiftUI
import AVKit
import SidebandCore

private let forest = Color(red: 0.14, green: 0.30, blue: 0.21)
private let paper = Color(red: 0.965, green: 0.97, blue: 0.95)
struct AudioRoutePicker: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView(); view.tintColor = UIColor(forest); view.activeTintColor = UIColor(forest); return view
    }
    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}
struct ListeningView: View {
    @StateObject private var model = ListeningModel()
    @Environment(\.scenePhase) private var scenePhase
    @State private var selected: Signal?
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("sideband", systemImage: "waveform.path").font(.system(size: 30, weight: .semibold, design: .rounded))
                            Text("A little more aware. A lot less screen.").font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "eyeglasses").font(.system(size: 34)).foregroundStyle(forest)
                    }
                    NavigationLink {
                        RevealView().navigationTitle("Reveal").navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("Reveal hidden image or text", systemImage: "eye")
                    }
                    VStack(alignment: .leading, spacing: 16) {
                        HStack { Text("Your listening session").font(.headline); Spacer(); Text(String(format: "%02d:%02d", model.elapsed / 60, model.elapsed % 60)).monospacedDigit() }
                        Picker("Session source", selection: $model.demo) { Text("Demo").tag(true); Text("iPhone Bluetooth").tag(false) }.pickerStyle(.segmented).disabled(model.running)
                        Text(model.demo ? "Simulated signals. Explore the experience." : "Foreground scanning. Keep Sideband open; locking your phone pauses this session.").font(.caption).foregroundStyle(.secondary)
                        Button { model.running ? model.stop() : model.start() } label: { Label(model.running ? "Stop listening" : "Start listening", systemImage: model.running ? "stop.fill" : "waveform").frame(maxWidth: .infinity).padding(6) }.buttonStyle(.borderedProminent).tint(forest)
                        Toggle("Quiet mode", isOn: $model.quiet)
                        Toggle("Spoken alerts", isOn: $model.voice)
                        Text(model.status).font(.callout).foregroundStyle(.secondary).accessibilityAddTraits(.updatesFrequently)
                    }.padding(20).background(.white).clipShape(RoundedRectangle(cornerRadius: 10))
                    VStack(alignment: .leading, spacing: 12) {
                        HStack { Text("Audio to your glasses").font(.headline); Spacer(); AudioRoutePicker().frame(width: 36, height: 36) }
                        Text("Output: \(model.audioRoute.isEmpty ? "Unavailable" : model.audioRoute)").font(.caption).foregroundStyle(.secondary)
                        Button("Play audio check") { model.testAudio() }.buttonStyle(.bordered)
                        Text("Bluetooth audio does not authenticate a Meta model. Confirm that you hear the check in your own glasses.").font(.caption).foregroundStyle(.secondary)
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        HStack { Text("Nearby signals").font(.headline); Spacer(); Text("\(model.signals.count) observed").font(.caption).foregroundStyle(.secondary) }
                        if model.signals.isEmpty { ContentUnavailableView("A moment of quiet", systemImage: "waveform.path", description: Text("Start a session. No observation does not mean no devices are nearby.")) }
                        ForEach(model.signals) { signal in
                            Button { selected = signal } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack { Text(signal.title).font(.subheadline.bold()); Spacer(); Image(systemName: "chevron.right").font(.caption) }
                                    HStack { Text(signal.id); Spacer(); Text("\(signal.medianRSSI) dBm"); Text(signal.ignored ? "Familiar" : signal.active(at: model.now) ? "Recently seen" : "Not recently seen") }.font(.caption).foregroundStyle(.secondary)
                                }.padding(.vertical, 12)
                            }.buttonStyle(.plain)
                            Divider()
                        }
                    }
                    if !model.signals.isEmpty {
                        HStack { Button("Hear recap") { model.speak((model.demo ? "Demo. " : "") + model.recap) }; Spacer(); ShareLink("Export", item: model.exportText); Button("Reset") { model.reset() } }.buttonStyle(.bordered)
                    }
                    Text("Possible presence. Never proof of recording.").font(.headline).foregroundStyle(forest)
                    Text("Signals can be missing or spoofed. Strength is not distance. No camera detection, person tracking, or all-clear guarantee. Observations stay in memory until you export or reset.").font(.caption).foregroundStyle(.secondary)
                }.padding(24)
            }.background(paper).toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selected) { signal in
                NavigationStack {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(signal.title).font(.title2.bold())
                        Text(signal.evidence)
                        LabeledContent("Source", value: model.demo ? "Simulation" : "iPhone Bluetooth")
                        LabeledContent("Service", value: signal.services.joined(separator: ", "))
                        LabeledContent("Observations", value: "\(signal.observations)")
                        LabeledContent("Recording", value: "Unknown")
                        Button(signal.ignored ? "Include in alerts again" : "This is mine · ignore alerts") { model.toggleIgnored(signal.id); selected = nil }.buttonStyle(.borderedProminent).tint(forest)
                        Text("Familiar status lasts for this session. Changing Bluetooth identifiers may appear as a new signal.").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                    }.padding(24).navigationTitle(signal.id).navigationBarTitleDisplayMode(.inline).toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { selected = nil } } }
                }.presentationDetents([.medium, .large])
            }
            .onChange(of: scenePhase) { _, phase in if phase == .background { model.suspend() } }
        }.tint(forest)
    }
}
