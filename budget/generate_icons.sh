#!/bin/bash
# Generate app icons for Android, iOS, and Web using flutter_launcher_icons

set -e

echo "🎨 Generating app icons..."

# Check if icon.png exists, if not create it from logo.png
ICON_PATH="assets/icon/icon.png"
if [ ! -f "$ICON_PATH" ]; then
    if [ -f "assets/icon/logo.png" ]; then
        echo "📋 icon.png not found, creating from logo.png..."
        cp "assets/icon/logo.png" "$ICON_PATH"
        echo "✅ Created icon.png from logo.png"
    else
        echo "❌ Error: No icon file found at assets/icon/icon.png or assets/icon/logo.png"
        exit 1
    fi
fi

echo "✅ Icon file ready: $ICON_PATH"

# Run flutter pub get to ensure dependencies are up to date
echo "📦 Updating dependencies..."
flutter pub get

# Generate icons
echo "🖼️  Generating icons for Android, iOS, and Web..."
flutter pub run flutter_launcher_icons

echo "✅ Icons generated successfully!"
echo ""
echo "Generated icons for:"
echo "  - Android (adaptive icons)"
echo "  - iOS (AppIcon)"
echo "  - Web (favicon and manifest icons)"

