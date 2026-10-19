# Verification

## Verified on 19 October 2026

- 10 JavaScript behavior tests passed on Ryzen and GitHub CI.
- 3 browser interaction tests passed on desktop and mobile-sized Chromium. Desktop/mobile screenshots were visually inspected. Tests exercise scenario switching, evidence selection, familiar status, quiet mode, recap, JSON download, pause/reset, keyboard activation and unavailable speech feedback.
- 10 Swift core tests passed on the macOS GitHub runner.
- Xcode successfully built the native iOS Simulator target without signing.
- Public GitHub Pages deployment returned HTTP200 with the expected Sideband page.

[Initial build evidence](https://github.com/rishvaiyer/sideband-glasses/actions/runs/39262969097). Native launch-and-listen UI automation is also included in CI; check the current run for its result. Browser checks are Chromium, not a claim of physical Mobile Safari testing.

## Physical acceptance still required

A signed iPhone install must demonstrate permission grant/denial, real advertisements, pause on background/lock, audio check through the intended glasses, route-loss behavior, familiar-device suppression and a recap. Both available Mac environments were checked: no valid signing identity was present, and neither had full Xcode. No device is claimed physically verified. No App Store, TestFlight or Meta marketplace submission is implied.

The unsigned simulator artifact is not an iPhone installation package. This boundary cannot be solved by calling the browser simulation a native app.
