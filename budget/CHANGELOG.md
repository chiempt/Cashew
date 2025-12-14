# Changelog

## [Unreleased]

### Android Build Fixes
- **Gradle & Kotlin Upgrade**: Fixed "Unresolved reference: filePermissions" and "BaseVariant" errors (Flutter 3.38.4 user branch requires Kotlin 2.0+):
  - Kotlin: 1.9.0 → 2.0.21 (required for Flutter 3.38.4's new Kotlin API, latest 2.0.x)
  - Gradle Plugin: 7.3.1 → 8.9.1 (required for androidx.core:core-ktx:1.17.0 and androidx.core:core:1.17.0 compatibility)
  - Gradle Wrapper: 8.0 → 8.11.1 (required for AGP 8.9.1 compatibility)
  - Updated settings.gradle plugin versions to match build.gradle (AGP 8.9.1, Kotlin 2.0.21)
  - Google Services: 4.3.14 → 4.4.0
  - Added `namespace` to build.gradle (required for Gradle 8.x)
  - Changed `lintOptions` to `lint` block (required for AGP 8.3+)
  - **Migrated to declarative plugins block**: Replaced `apply from` with `plugins { id "dev.flutter.flutter-gradle-plugin" }` and moved to top of file (required for Flutter 3.38.4)
  - **Updated desugar_jdk_libs**: 1.2.2 → 2.1.4 (required by flutter_local_notifications dependency)
- **Removed deprecated jcenter() repository**: Removed `jcenter()` from `settings.gradle` dependencyResolutionManagement repositories. JCenter was shut down in 2021 and causes build failures when Gradle tries to resolve dependencies from it. Flutter engine artifacts are now resolved from Google Maven, Maven Central, and local Maven repositories only.
- **Installed Android SDK cmdline-tools**: Installed latest Android SDK command-line tools to `/Users/chiempham/Library/Android/sdk/cmdline-tools/latest/` to fix "Android sdkmanager not found" error when running `flutter doctor --android-licenses`. All Android SDK package licenses have been accepted.
- **Fixed notification_listener_service namespace issue**: Created `fix_notification_listener_namespace.sh` script to automatically add missing `namespace` declaration to `notification_listener_service` plugin's build.gradle file. This is required for AGP 8.x compatibility. The script is automatically executed by `pub_get.sh` wrapper after each `flutter pub get` to ensure the fix persists across dependency updates.

### UI/UX Improvements
- **Enhanced Bottom Navigation Bar Design**: 
  - Added rounded top corners (20px radius) for modern look
  - Improved shadow effects with better blur and offset for depth
  - Enhanced icon animations with smooth scale transitions (1.0 to 1.1)
  - Better visual feedback with animated container backgrounds
  - Improved color contrast for selected/unselected states
  - Added subtle shadow to selected icon indicators
  - Increased padding for better touch targets
  - Applied consistent styling across iOS and Android platforms

### Architecture Decisions
- **Bottom Navigation Bar Refactoring**: Replaced ScaleIn widget with AnimatedContainer and AnimatedScale for better control and smoother animations. This provides more granular control over animation timing and visual effects.

### Dependencies
- **Added `flutter_local_notifications_linux`**: Added to suppress Flutter warnings about missing Linux implementation for `flutter_local_notifications`. Note: App currently doesn't support Linux platform for notifications (see `notificationsSettings.dart` line 503), but adding this dependency eliminates the warning during `flutter pub get`.

### Package Updates
- **Updated packages for Xcode 26 compatibility**:
  - `carousel_slider`: 4.2.1 → 5.1.1 (fix conflict with Flutter's built-in CarouselController)
  - `device_preview`: 1.1.0 → 1.3.1 (fix deprecated APIs)
  - `flutter_sticky_header`: 0.6.5 → 0.8.0 (fix hashValues issue)
  - `home_widget`: 0.5.0 → 0.8.1 (fix size parameter issue)
  - `value_layout_builder`: 0.3.1 → 0.5.0 (transitive dependency, fix missing implementations)

### iOS Build Fixes
- **iOS Deployment Target**: Updated from iOS 13.0 to iOS 17.0
- **Xcode 26 Compatibility**: 
  - Fixed `-G` flag unsupported error by disabling `GCC_GENERATE_DEBUGGING_SYMBOLS` and removing flag from compiler settings
  - Added `fix_xcode26.xcconfig` to override build settings
  - Updated Podfile post_install hook to remove unsupported flags
  - Patched Flutter build script to remove incompatible flags
  - Created helper scripts for build process patching

### Package Warnings
- **Disabled desktop platforms support**: Disabled Linux, macOS, and Windows desktop platforms in Flutter config (`flutter config --no-enable-linux-desktop --no-enable-macos-desktop --no-enable-windows-desktop`) since the app only targets mobile (Android/iOS) and web platforms. This reduces unnecessary plugin resolution for desktop platforms.
- **Package warnings handling**: The warnings about `file_picker` missing inline implementations for desktop platforms (Linux, macOS, Windows) are from the git fork being used (`melWiss/flutter_file_picker`). These warnings don't affect mobile/web functionality and are expected until the fork maintainer adds inline implementations. The warnings can be filtered when running `flutter pub get` if needed.



  PipeArtXAI keytool -list -v \
-alias androiddebugkey \
-keystore ~/.android/debug.keystore \
-storepass android \
-keypass android

Alias name: androiddebugkey
Creation date: Nov 1, 2023
Entry type: PrivateKeyEntry
Certificate chain length: 1
Certificate[1]:
Owner: C=US, O=Android, CN=Android Debug
Issuer: C=US, O=Android, CN=Android Debug
Serial number: 1
Valid from: Wed Nov 01 23:27:16 ICT 2023 until: Fri Oct 24 23:27:16 ICT 2053
Certificate fingerprints:
	 SHA1: DE:29:AD:49:F3:03:F9:37:26:C2:C6:27:68:A1:F3:F2:05:4F:94:01
	 SHA256: BB:4E:A9:EC:54:2F:1C:BB:F8:27:A7:49:44:13:EE:00:80:13:83:1E:78:79:EF:81:8B:DB:A5:76:91:21:F5:52
Signature algorithm name: SHA1withRSA (weak)
Subject Public Key Algorithm: 2048-bit RSA key
Version: 1

Warning:
The certificate uses the SHA1withRSA signature algorithm which is considered a security risk.
➜  PipeArtXAI 
