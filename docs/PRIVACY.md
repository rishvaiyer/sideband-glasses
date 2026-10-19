# Privacy and limitations

Sideband's native app keeps observations in session memory. It stores a session alias, advertised service UUIDs, RSSI samples, observation times and familiar/ignored status. It does not retain peripheral names, raw manufacturer payloads, stable device IDs, images, microphone recordings or location. In-memory peripheral UUID mapping ends when the session resets. No connections to observed peripherals are initiated.

Export is explicit and shares the session through the operating system. The recipient of an exported file is outside Sideband's control. Reset discards local session state; copies already exported remain wherever you shared them.

The web demo processes synthetic data in the page and exports only when selected. Speech uses the platform's speech service and audio route, whose implementation varies. Hosting providers receive ordinary web request metadata. There are no analytics scripts or accounts.

The native app requires a headphone/Bluetooth audio route before speech. It stops speech on loss of that route, but physical route-transition behavior still requires testing. It does not authenticate which glasses model is selected.

The initial FD5F rule identifies an advertised service associated with Meta, not a particular product, person, recording state or threat. Advertisements are untrusted and may be spoofed. Devices that do not advertise a recognizable service are not identified. No detections is not an all-clear result. Phone locking/backgrounding stops this version's scan. Native device testing remains a separate acceptance gate.
