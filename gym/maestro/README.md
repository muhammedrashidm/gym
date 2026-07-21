# Maestro — initial setup

Status of this setup, as of the last check from this machine:

| Prerequisite | Status |
|---|---|
| Java (Maestro needs 11+) | ✅ found — OpenJDK 21.0.8 (`JAVA_HOME=C:\Program Files\Android\Android Studio\jbr`) |
| Maestro CLI | ❌ not installed (`maestro` not found on PATH) |
| Android SDK / `adb` | ✅ present (`platform-tools` already on PATH) |

## Install Maestro (Windows)

Native Windows support — run in **PowerShell**:

```powershell
irm https://get.maestro.mobile.dev/windows | iex
```

This installs to `%USERPROFILE%\.maestro\bin` and adds it to your user PATH. **Open a new terminal** after installing (PATH changes don't apply to already-open shells).

Alternative (if you prefer WSL2 or a Unix-style shell such as Git Bash — this is the cross-platform installer used on macOS/Linux):

```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
```

I did not run either of these myself — installing a CLI system-wide from a remote script is worth doing with your own eyes on it. Run whichever matches your setup, then verify:

```
maestro --version
```

## App identifiers (for flow files' `appId:` field)

From `android/app/build.gradle.kts`, per flavor:

| Flavor | `applicationId` |
|---|---|
| dev | `com.capecode.kinetic.gym.dev` |
| staging | `com.capecode.kinetic.gym.staging` |
| prod | `com.capecode.kinetic.gym` |

Local dev testing will almost always target the `dev` flavor (`com.capecode.kinetic.gym.dev`), matching `flutter run --flavor dev -t lib/main_dev.dart` and the dev API at `192.168.0.11:3000`.

## Directory layout (created, empty for now)

```
gym/
├── maestro/
│   ├── config.yaml          # workspace config — flow glob + appId reference table
│   ├── README.md            # this file
│   └── flows/
│       ├── auth/            # (empty) auth flow YAMLs go here next
│       └── regression/      # (empty) regression suite YAMLs go here next
└── tests/
    └── screenshots/         # (empty) Maestro failure/debug screenshots land here
```

## Next steps (not done yet)

This step only covers install + scaffolding. Still to come once you confirm Maestro is installed and an emulator/device is available: the actual auth flow YAMLs (mobile number entry, OTP verification, login/logout, session persistence), a regression suite, and wiring screenshot capture into `tests/screenshots/`.
