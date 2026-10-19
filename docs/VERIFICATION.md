# Verification

## Verified on 19 October 2026

- 11 JavaScript behavior tests passed on Ryzen and GitHub CI.
- 3 browser interaction tests passed on desktop and mobile-sized Chromium. Desktop/mobile screenshots were visually inspected. Tests exercise scenario switching, evidence selection, familiar status, quiet mode, recap, JSON download, pause/reset, keyboard activation and unavailable speech feedback.
- 11 Swift core tests passed on the macOS GitHub runner.
- Xcode successfully built the native iOS Simulator target without signing.
- Public GitHub Pages deployment returned HTTP200 with the expected Sideband page.

[Passing verification run](https://github.com/rishvaiyer/sideband-glasses/actions/runs/39265472511), tested code commit `9971c9e`: **26 automated tests passed** (11 JavaScript core, 3 browser, 11 Swift core, 1 native UI). The native app installed and launched on the GitHub-hosted Intel iPhone simulator. The UI test exercised Start/Stop, and the captured launch screen was visually inspected. Earlier ARM simulator runs failed in runner startup or installation; the Intel run passed without weakening OS protections.

[Native simulator screenshot](iphone-simulator.png). This is simulator evidence, not a photograph or physical iPhone check. Browser checks use Chromium, not physical Mobile Safari.

## Physical acceptance still required

A signed iPhone install must demonstrate permission grant/denial, real advertisements, pause on background/lock, audio check through the intended glasses, route-loss behavior, familiar-device suppression and a recap. Both available Mac environments were checked: no valid signing identity was present, and neither had full Xcode. No device is claimed physically verified. No App Store, TestFlight or Meta marketplace submission is implied.

The unsigned simulator artifact is not an iPhone installation package. This boundary cannot be solved by calling the browser simulation a native app.
