# Direct sources checked 19 October 2026

- [Bluetooth SIG Assigned Numbers](https://www.bluetooth.com/wp-content/uploads/Files/Specification/HTML/Assigned_Numbers/out/en/index-en.html): FD5F is assigned to Meta Platforms Technologies, LLC. Assignment is not a unique product fingerprint.
- [Apple Bluetooth background behavior](https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/CoreBluetoothBackgroundProcessingForIOSApps/PerformingTasksWhileYourAppIsInTheBackground.html): foreground and background scanning have different constraints. This app explicitly stops when inactive.
- [Apple Bluetooth A2DP routing](https://developer.apple.com/documentation/avfaudio/avaudiosession/categoryoptions-swift.struct/allowbluetootha2dp): playback sessions support A2DP output routes.
- [Apple AVSpeechSynthesizer](https://developer.apple.com/documentation/avfaudio/avspeechsynthesizer): native spoken output.
- [Meta Wearables FAQ](https://developers.meta.com/wearables/faq/): the Device Access Toolkit and display-only Web Apps are separate paths. Sideband's current audio-only implementation uses neither and does not claim Meta SDK approval.
- [Meta iOS toolkit](https://github.com/facebook/meta-wearables-dat-ios): reference for future deliberate camera/context integration; no SDK binaries are redistributed here.

The Eye Spy project informed the initial question and service-rule choice. Sideband code was written separately, and does not redistribute private Eye Spy source, device records, account data or history.
