#!/bin/bash
# Fix Android installation issues, particularly INSTALL_FAILED_USER_RESTRICTED

set -e

PACKAGE_NAME="com.money.manager.budget.tracker"
APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"

echo "🔧 Fixing Android installation issues..."

# Check if device is connected
if ! adb devices | grep -q "device$"; then
    echo "❌ No Android device connected or device not authorized"
    echo "Please:"
    echo "  1. Connect your device via USB"
    echo "  2. Enable USB debugging on your device"
    echo "  3. Accept the USB debugging authorization prompt on your device"
    exit 1
fi

echo "✅ Device connected"

# Get device info
DEVICE_ID=$(adb devices | grep "device$" | head -1 | awk '{print $1}')
echo "📱 Device: $DEVICE_ID"

# Step 1: Uninstall existing app if present
echo ""
echo "Step 1: Uninstalling existing app (if present)..."
if adb -s "$DEVICE_ID" shell pm list packages | grep -q "$PACKAGE_NAME"; then
    echo "   Found existing installation, uninstalling..."
    adb -s "$DEVICE_ID" uninstall "$PACKAGE_NAME" 2>/dev/null || {
        echo "   ⚠️  Could not uninstall (may require manual uninstall)"
    }
else
    echo "   No existing installation found"
fi

# Step 2: Check if APK exists
if [ ! -f "$APK_PATH" ]; then
    echo ""
    echo "❌ APK not found at $APK_PATH"
    echo "Building APK first..."
    flutter build apk --debug
fi

# Step 3: Try installation with different methods
echo ""
echo "Step 2: Attempting installation..."

# Method 1: Standard install
echo "   Trying standard install..."
if adb -s "$DEVICE_ID" install "$APK_PATH" 2>&1 | grep -q "Success"; then
    echo "   ✅ Installation successful!"
    exit 0
fi

# Method 2: Install with -r (replace) flag
echo "   Trying install with replace flag..."
if adb -s "$DEVICE_ID" install -r "$APK_PATH" 2>&1 | grep -q "Success"; then
    echo "   ✅ Installation successful!"
    exit 0
fi

# Method 3: Install with -d (downgrade) flag
echo "   Trying install with downgrade flag..."
if adb -s "$DEVICE_ID" install -d "$APK_PATH" 2>&1 | grep -q "Success"; then
    echo "   ✅ Installation successful!"
    exit 0
fi

# Method 4: Install with -g (grant permissions) flag
echo "   Trying install with grant permissions flag..."
if adb -s "$DEVICE_ID" install -g "$APK_PATH" 2>&1 | grep -q "Success"; then
    echo "   ✅ Installation successful!"
    exit 0
fi

# If all methods fail, provide manual instructions
echo ""
echo "❌ Automatic installation failed"
echo ""
echo "Manual steps to fix INSTALL_FAILED_USER_RESTRICTED:"
echo ""
echo "1. On your Android device:"
echo "   - Go to Settings > Security (or Settings > Apps > Special access)"
echo "   - Find 'Install unknown apps' or 'Install apps from unknown sources'"
echo "   - Enable it for your current app/launcher"
echo ""
echo "2. If using Android 8.0+:"
echo "   - Go to Settings > Apps > Special access > Install unknown apps"
echo "   - Enable for the app you're using to install (ADB, File Manager, etc.)"
echo ""
echo "3. Try installing via Flutter:"
echo "   flutter install"
echo ""
echo "4. Or manually via ADB with user confirmation:"
echo "   adb install -r -d -g $APK_PATH"
echo ""
echo "5. If still failing, check device logs:"
echo "   adb logcat | grep -i install"
echo ""

exit 1

