# CHANGELOG

## [2025-12-XX] - Gradle Plugin Migration

### Architecture Decisions

#### Flutter Gradle Plugin Migration to Declarative Plugins Block
- **Decision**: Migrated from imperative `apply from` method to declarative `plugins` block in `settings.gradle`
- **Reason**: Flutter 3.38.4 requires using the new declarative plugins block instead of the deprecated `apply from` method for `app_plugin_loader.gradle`
- **Implementation**:
  - Updated `budget/android/settings.gradle` to use `pluginManagement` block with `includeBuild` for Flutter tools
  - Applied `dev.flutter.flutter-plugin-loader` plugin using declarative `plugins` block
  - Removed deprecated `apply from: "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle"` line
- **Impact**: Resolves Gradle build errors related to plugin loading. This is a breaking change in Flutter's build system that requires all projects to migrate.

#### Gradle Version Update
- **Decision**: Updated Gradle from 7.5 to 8.0
- **Reason**: Better compatibility with newer Flutter versions and declarative plugins block
- **Implementation**: Updated `budget/android/gradle/wrapper/gradle-wrapper.properties`
- **Impact**: Improved build performance and compatibility with modern Android build tools

### Technical Notes
- The migration follows Flutter's official migration guide: https://flutter.dev/to/flutter-gradle-plugin-apply
- All Gradle plugin applications now use the declarative syntax which is the recommended approach going forward

