# Changelog

## [Unreleased]

### Development Tools
- **Package name change script**: Created `change_package_name.sh` script to automatically change Android package name throughout the entire project. The script:
  - Auto-detects current package name from `android/app/build.gradle` if only new package name is provided
  - Updates all AndroidManifest.xml files, build.gradle files, Kotlin source files
  - Moves Kotlin source directories to match new package structure
  - Updates Dart files, JSON files, and iOS configuration files
  - Handles legacy directory structures automatically
  - Usage: `./change_package_name.sh <new_package_name>` or `./change_package_name.sh <old_package> <new_package>`
- **Android installation fix scripts**: Created scripts to handle `INSTALL_FAILED_USER_RESTRICTED` errors:
  - `fix_android_install.sh`: Comprehensive script that uninstalls existing app, tries multiple installation methods with different ADB flags (-r, -d, -g), and provides manual instructions if automatic fix fails
  - `flutter_install.sh`: Wrapper for `flutter install` that automatically detects and handles USER_RESTRICTED errors, attempts workarounds, and provides clear error messages
  - Both scripts check device connectivity, handle APK building if needed, and provide step-by-step manual instructions when automatic fixes fail

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
  - **Switched file_picker to pub.dev version**: Changed from git fork (`melWiss/flutter_file_picker`) to official pub.dev version `^10.3.7` to avoid V1 embedding compatibility issues
  - **Fixed plugin V1 embedding compatibility**: Removed deprecated `registerWith` method and updated `setup` methods to remove dependency on `PluginRegistry.Registrar` (which was removed in newer Flutter versions) for:
    - `image_picker_android`
    - `in_app_purchase_android`
    - Created automated patch scripts (`fix_image_picker_v1_embedding.sh` and `fix_in_app_purchase_v1_embedding.sh`) that run after `flutter pub get` to ensure fixes persist across dependency updates
    - All plugins now only use V2 embedding which is the standard for modern Flutter apps
- **Removed deprecated jcenter() repository**: Removed `jcenter()` from `settings.gradle` dependencyResolutionManagement repositories. JCenter was shut down in 2021 and causes build failures when Gradle tries to resolve dependencies from it. Flutter engine artifacts are now resolved from Google Maven, Maven Central, and local Maven repositories only.
- **Installed Android SDK cmdline-tools**: Installed latest Android SDK command-line tools to `/Users/chiempham/Library/Android/sdk/cmdline-tools/latest/` to fix "Android sdkmanager not found" error when running `flutter doctor --android-licenses`. All Android SDK package licenses have been accepted.
- **Fixed notification_listener_service namespace issue**: Created `fix_notification_listener_namespace.sh` script to automatically add missing `namespace` declaration to `notification_listener_service` plugin's build.gradle file. This is required for AGP 8.x compatibility. The script is automatically executed by `pub_get.sh` wrapper after each `flutter pub get` to ensure the fix persists across dependency updates.

### Bug Fixes
- **Fixed "Looking up a deactivated widget's ancestor is unsafe" error**: Fixed runtime error in `openPopup`, `openPopupCustom`, and `openLoadingPopup` functions where `Theme.of(context)` and `MediaQuery.paddingOf(context)` were being called with context from `pageBuilder` callback parameter, which may be deactivated. Wrapped dialog content in `Builder` widget to ensure valid Theme context is available when accessing Theme and MediaQuery.

### UI/UX Improvements
- **Modern Black Primary Color**: Implemented sophisticated black primary color for the entire app:
  - **Light Mode**: `#0F172A` (Slate 900) - modern, elegant black with subtle blue undertone
  - **Dark Mode**: `#E2E8F0` (Slate 200) - light gray for excellent visibility in dark theme
  - Provides premium, sophisticated, and ultra-modern appearance
  - Perfect for high-end financial/budget apps - very contemporary and refined
  - Excellent contrast in light mode, optimal visibility in dark mode
  - Applied adaptively based on theme brightness
  - Overrides primary color in `getColorScheme()` while maintaining accent color flexibility for other UI elements
  - This modern black color scheme provides a premium, minimalist, and sophisticated look
- **Home Page UI Modernization**: Enhanced home page with modern design improvements:
  - **Improved Spacing**: Increased spacing between sections (16px) for better visual hierarchy and breathing room
  - **Modern Header**: Enhanced header layout with better padding, modernized icon button with Material InkWell ripple effect
  - **Refined Background**: Subtle gradient adjustments (reduced opacity from 0.15 to 0.12 for light mode) and refined pattern (spacing 140px, radius 1.5px) for cleaner look
  - **Better Section Spacing**: Added intelligent spacing between sections with proper top padding (8px for first, 16px for others)
  - **Enhanced Rating Box**: Modernized rating box with increased padding (20px), larger border radius (20px), improved typography (24px title with -0.3 letter spacing), and better button spacing
  - **Increased Bottom Padding**: Extended bottom padding from 73px to 80px for better scroll experience
  - Overall cleaner, more spacious, and modern appearance
- **Android Bottom Navigation Bar**: Replaced Material NavigationBar with Google Nav Bar (`google_nav_bar` package) for Android platform:
  - Modern Google-style navigation bar with smooth animations and professional styling
  - **FontAwesome Icons**: Switched to FontAwesome icons for main navigation items (home, transactions, budgets, more) for better visual consistency
  - **Enhanced Active State**: Improved active state visibility in light theme with full opacity primary color and optimized background color
  - Enhanced dark theme support: Active color automatically lightened for better visibility in dark mode
  - Improved spacing and padding for better touch targets and visual hierarchy
  - Professional typography with custom font support and letter spacing
  - Smooth cubic easing animations (400ms duration)
  - Adaptive colors for ripple and hover effects based on theme
  - Maintains all existing functionality (customizable shortcuts, dark/light mode support)
  - Long press on customizable tabs (first 3 tabs) to change shortcuts
  - iOS navigation bar remains unchanged
  - Supports Material You theming and custom accent colors
- **Home Page Default Order**: Optimized default home page section order for better user flow:
  1. **Wallets** (Tài khoản) - Primary account balance and switcher
  2. **Wallets List** (Danh sách tài khoản) - All accounts overview
  3. **All Spending Summary** (Tổng quan Thu & Chi) - Overall financial summary
  4. **Budgets** (Ngân sách) - Active budgets for expense control
  5. **Transactions List** (Danh sách giao dịch) - Recent transactions
  6. **Spending Graph** (Biểu đồ xu hướng) - Spending trends over time
  7. **Pie Chart** (Biểu đồ tròn) - Category breakdown
  8. **Heat Map** (Bản đồ nhiệt) - Time-based spending analysis
  9. **Objectives** (Mục tiêu) - Financial goals
  10. **Net Worth** (Tài sản ròng) - Overall net worth
  11. **Overdue Upcoming** (Giao dịch sắp đến) - Upcoming/overdue transactions
  12. **Credit Debts** (Nợ tín dụng) - Credit card debts
  13. **Objective Loans** (Khoản vay) - Loan objectives
  - Applied to both regular layout (`homePageOrder`) and full-screen double-column layout (`homePageOrderFullScreen`)
  - Order prioritizes: Account info → Financial overview → Budget control → Transaction details → Analytics → Goals
- **Enhanced Bottom Navigation Bar Design**: 
  - Added rounded top corners (20px radius) for modern look
  - Improved shadow effects with better blur and offset for depth
  - Enhanced icon animations with smooth scale transitions (1.0 to 1.1)
  - Better visual feedback with animated container backgrounds
  - Improved color contrast for selected/unselected states
  - Added subtle shadow to selected icon indicators
  - Increased padding for better touch targets
  - Applied consistent styling across iOS and Android platforms
- **Professional Onboarding Experience**:
  - Replaced elastic page transitions with smooth cubic easing (600ms duration) for more polished feel
  - Added staggered slide-fade animations for all content elements with progressive delays (100-500ms)
  - Enhanced image presentation with rounded corners (20px), subtle shadows, and proper clipping
  - Improved typography hierarchy with larger titles (28px), better letter spacing (-0.5), and refined text colors
  - Better spacing between elements (increased from 15px to 20-30px for better breathing room)
  - Enhanced gradient overlay at bottom with smoother 3-stop gradient for better visual fade
  - Added per-page fade animations that trigger when each page becomes active
  - Improved visual consistency across all three onboarding pages with unified animation timing
  - **Professional Page Indicator**: Redesigned page indicator dots with modern pill-shaped active state:
    - Active dot expands to 24px width (3x wider) instead of just scaling up
    - Smooth 300ms cubic easing transitions between states
    - Better color opacity and visual hierarchy (active: 100% opacity, inactive: 25-40% opacity)
    - Rounded corners (4px radius) for modern appearance
    - Smooth interpolation during page transitions for fluid user experience
  - **Professional Navigation Buttons**: Enhanced next/previous buttons with modern design:
    - Larger button size (56px) with rounded corners (16px radius) for better touch targets
    - Dual-layer shadow system (primary shadow 12px blur, secondary shadow 4px blur) for depth
    - Smooth scale animation (0.92x) on tap with 150ms duration for tactile feedback
    - Animated opacity and scale transitions (300ms) when buttons appear/disappear
    - Material You support with adaptive opacity for secondary container
    - Professional visual hierarchy with proper icon sizing (28px) and spacing

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
