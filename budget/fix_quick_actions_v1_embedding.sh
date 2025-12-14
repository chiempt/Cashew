#!/bin/bash
# Script to fix quick_actions_android plugin V1 embedding compatibility issue
# Removes deprecated registerWith method

QUICK_ACTIONS_PLUGIN_PATH="$HOME/.pub-cache/hosted/pub.dev/quick_actions_android-*/android/src/main/java/io/flutter/plugins/quickactions/QuickActionsPlugin.java"

# Find the actual file path
ACTUAL_PATH=$(find "$HOME/.pub-cache/hosted/pub.dev" -name "QuickActionsPlugin.java" -path "*/quickactions/*" 2>/dev/null | head -1)

if [ -z "$ACTUAL_PATH" ] || [ ! -f "$ACTUAL_PATH" ]; then
    # File not found, skip
    exit 0
fi

# Check if already fixed (no registerWith method)
if ! grep -q "public static void registerWith" "$ACTUAL_PATH" 2>/dev/null; then
    # Already fixed
    exit 0
fi

# Check if PluginRegistry.Registrar is used
if ! grep -q "PluginRegistry.Registrar" "$ACTUAL_PATH" 2>/dev/null; then
    # Already fixed
    exit 0
fi

echo "Fixing quick_actions_android plugin V1 embedding compatibility..."

# Create a backup
cp "$ACTUAL_PATH" "${ACTUAL_PATH}.bak"

# Remove the registerWith method
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS sed
    # Remove registerWith method (from /** Plugin registration. */ to closing brace)
    sed -i.bak2 '/\/\*\* Plugin registration\./,/^  }$/{
        /public static void registerWith/,/^  }$/d
    }' "$ACTUAL_PATH"
    
    # Remove comment if it exists
    sed -i.bak3 '/Removed registerWith method/d' "$ACTUAL_PATH"
    
    # Clean up backup files
    rm -f "${ACTUAL_PATH}.bak" "${ACTUAL_PATH}.bak2" "${ACTUAL_PATH}.bak3" 2>/dev/null
else
    # Linux sed
    sed -i '/\/\*\* Plugin registration\./,/^  }$/{
        /public static void registerWith/,/^  }$/d
    }' "$ACTUAL_PATH"
    
    sed -i '/Removed registerWith method/d' "$ACTUAL_PATH"
fi

echo "  ✓ Fixed quick_actions_android plugin V1 embedding compatibility"
