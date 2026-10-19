import json, subprocess, pathlib
result = json.loads(subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "--json"]))
phones = [d for group in result["devices"].values() for d in group if d["name"].startswith("iPhone") and d.get("isAvailable")]
if not phones: raise SystemExit("No iPhone simulator installed")
device = phones[0]["udid"]
subprocess.run(["xcodebuild", "test", "-project", "ios/Sideband.xcodeproj", "-scheme", "Sideband", "-destination", "platform=iOS Simulator,id="+device, "-derivedDataPath", "build", "-resultBundlePath", "build/SidebandTests.xcresult", "-parallel-testing-enabled", "NO", "-test-timeouts-enabled", "YES", "-default-test-execution-time-allowance", "60", "-maximum-test-execution-time-allowance", "120", "CODE_SIGNING_ALLOWED=NO"], check=True, timeout=600)
subprocess.run(["xcrun", "simctl", "launch", device, "app.sideband.glasses"], check=True)
pathlib.Path("build/evidence").mkdir(exist_ok=True)
subprocess.run(["xcrun", "simctl", "io", device, "screenshot", "build/evidence/iphone.png"], check=True)
