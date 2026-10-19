# Architecture

## Two runnable surfaces

The web demo is a static page with a deterministic scenario generator feeding a small signal engine. It supports explicit audio opt-in, per-session familiar-device suppression, a global 30-second speech cooldown, a minimum of 3 observations spanning 2 seconds, evidence inspection and bounded JSON export. It pauses when hidden. Scenario changes reset the session.

The SwiftUI iPhone app uses CoreBluetooth scanning on the main queue. It requests Bluetooth permission only when the real listening mode is started. It observes advertised service UUIDs without connecting to nearby devices. A platform-independent Swift core handles evidence accumulation and alerts. Swift and JavaScript behavior is covered by parallel tests. No automatic identity or recording inference is made.

Both engines cap signals at 128 and RSSI samples at 20 per signal, reject invalid/unavailable RSSI and out-of-order timestamps, and mark observations stale after 20 seconds. Median RSSI is a signal measurement, not a distance estimator. At capacity, new signals are not admitted until a reset; this is a bounded demo tradeoff.

## Glasses integration

Audio goes through the standard iOS playback audio session and the user's chosen route. A route picker and spoken check are provided. This works at the Bluetooth audio abstraction; it is not a DAT camera or device-authentication integration. Camera/context additions should be a separate opt-in feature with current SDK, licensing, consent and hardware verification. This version deliberately requires neither a Meta developer account nor a cloud model.

## State boundaries

Demo and live sessions cannot run together. Stop/backgrounding cancels requested scanning and timers. Voice is off initially. Quiet mode prevents automatic speech; an explicitly requested recap can still speak. Familiar status is local to a session and can fail to recognize a device after identifier rotation. Speech is once per signal per session, with global cooldown; no continuous warning loop.

## Cross-device work

GitHub is the shared source. Clone the public repository on any development machine. Ryzen hosts development and the local demo; macOS or the macOS CI runner builds the iOS target. Device installation needs Apple's signing flow. The static browser demo is accessible from iPhone, Mac and Linux and does not require a local service for normal use.
