#!/bin/bash
# Wrapper for flutter install that handles INSTALL_FAILED_USER_RESTRICTED

set -e

PACKAGE_NAME="com.money.manager.budget.tracker"
DEVICE_ID=$(adb devices | grep "device$" | head -1 | awk '{print $1}' || echo "")

if [ -z "$DEVICE_ID" ]; then
    echo "❌ No Android device connected"
    exit 1
fi

echo "📱 Installing on device: $DEVICE_ID"

# Try flutter install first
if flutter install 2>&1 | tee /tmp/flutter_install.log; then
    echo "✅ Installation successful via flutter install"
    exit 0
fi

# Check if it's the USER_RESTRICTED error
if grep -q "INSTALL_FAILED_USER_RESTRICTED\|Install canceled by user" /tmp/flutter_install.log; then
    echo ""
    echo "⚠️  INSTALL_FAILED_USER_RESTRICTED detected"
    echo "Attempting workaround..."
    
    # Uninstall existing app first
    if adb -s "$DEVICE_ID" shell pm list packages | grep -q "$PACKAGE_NAME"; then
        echo "Uninstalling existing app..."
        adb -s "$DEVICE_ID" uninstall "$PACKAGE_NAME" 2>/dev/null || true
    fi
    
    # Build APK if needed
    if [ ! -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
        echo "Building APK..."
        flutter build apk --debug
    fi
    
    # Try install with all flags
    echo "Installing with workaround flags..."
    if adb -s "$DEVICE_ID" install -r -d -g "build/app/outputs/flutter-apk/app-debug.apk" 2>&1 | grep -q "Success"; then
        echo "✅ Installation successful!"
        exit 0
    fi
    
    echo ""
    echo "❌ Installation still failed. Please:"
    echo "   1. On your device: Settings > Security > Install unknown apps"
    echo "   2. Enable installation for your current app/launcher"
    echo "   3. Or run: ./fix_android_install.sh"
    exit 1
fi

# Other errors - just show the log
cat /tmp/flutter_install.log
exit 1

