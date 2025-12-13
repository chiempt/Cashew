#!/bin/bash
# Patch Flutter build to remove -G flag for Xcode 26 compatibility

FLUTTER_ROOT="${FLUTTER_ROOT:-/Users/chiempham/development/flutter}"
XCODE_BACKEND="$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh"

if [ -f "$XCODE_BACKEND" ]; then
    # Create backup if not exists
    if [ ! -f "$XCODE_BACKEND.backup" ]; then
        cp "$XCODE_BACKEND" "$XCODE_BACKEND.backup"
    fi
    
    # Remove -G flag from the script
    sed -i '' 's/\b-G\b//g' "$XCODE_BACKEND" 2>/dev/null || true
    echo "Patched Flutter build script"
else
    echo "Flutter build script not found at $XCODE_BACKEND"
fi

