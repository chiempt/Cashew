# Changelog

## [Unreleased]

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
- **Package warnings handling**: The warnings about `file_picker` missing inline implementations for desktop platforms (Linux, macOS, Windows) are from the git fork being used (`melWiss/flutter_file_picker`). These warnings don't affect mobile/web functionality and are expected until the fork maintainer adds inline implementations. No action needed as app primarily targets mobile platforms.

