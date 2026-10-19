import json, subprocess, pathlib, time
result = json.loads(subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "--json"]))
phones = [d for group in result["devices"].values() for d in group if d["name"].startswith("iPhone") and d.get("isAvailable")]
if not phones: raise SystemExit("No iPhone simulator installed")
phone = phones[0]; device = phone["udid"]
if phone["state"] != "Booted": subprocess.run(["xcrun", "simctl", "boot", device], check=True, timeout=60)
subprocess.run(["xcrun", "simctl", "bootstatus", device, "-b"], check=True, timeout=240)
subprocess.run(["open", "-a", "Simulator"], check=True, timeout=30)
subprocess.run(["xcrun", "simctl", "install", device, "build/Build/Products/Debug-iphonesimulator/Sideband.app"], check=True, timeout=60)
subprocess.run(["xcrun", "simctl", "launch", device, "app.sideband.glasses"], check=True, timeout=60)
time.sleep(5)
pathlib.Path("build/evidence").mkdir(exist_ok=True)
subprocess.run(["xcrun", "simctl", "io", device, "screenshot", "build/evidence/iphone.png"], check=True, timeout=30)
subprocess.run(["xcodebuild", "test", "-project", "ios/Sideband.xcodeproj", "-scheme", "Sideband", "-destination", "platform=iOS Simulator,id="+device, "-derivedDataPath", "build", "-resultBundlePath", "build/SidebandTests.xcresult", "-parallel-testing-enabled", "NO", "-test-timeouts-enabled", "YES", "-default-test-execution-time-allowance", "60", "-maximum-test-execution-time-allowance", "120", "CODE_SIGNING_ALLOWED=NO"], check=True, timeout=600)
