# Simple AdMob Android Plugin (Godot 4.3+)

This module builds the Android AAR files consumed by `addons/simple_admob/export_plugin.gd`.

## Build requirements

- Android Studio or Gradle wrapper
- Android SDK (compileSdk 35)
- JDK 17

## Build steps

1. Open `tools/simple_admob_android` in Android Studio.
2. Sync Gradle project.
3. Build AARs:
   - Debug: `:plugin:assembleDebug`
   - Release: `:plugin:assembleRelease`
4. Copy artifacts:
   - Run `tools/simple_admob_android/copy_aars.ps1`
   - Or manually copy:
     - `plugin/build/outputs/aar/plugin-debug.aar` -> `addons/simple_admob/bin/debug/simple-admob-debug.aar`
     - `plugin/build/outputs/aar/plugin-release.aar` -> `addons/simple_admob/bin/release/simple-admob-release.aar`

## Notes

- Keep Godot export option `Use Gradle Build = true`.
- The plugin injects AdMob app id into Android manifest from `ProjectSettings` key `admob/app_id/android`.

## Optional: Generate Gradle Wrapper

If `gradlew` is missing on your machine, run from this folder:

```powershell
gradle wrapper --gradle-version 8.7
```
