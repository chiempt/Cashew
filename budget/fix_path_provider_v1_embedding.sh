#!/bin/bash
# Script to fix path_provider_android plugin V1 embedding compatibility issue
# Removes deprecated registerWith method

PATH_PROVIDER_PLUGIN_PATH="$HOME/.pub-cache/hosted/pub.dev/path_provider_android-*/android/src/main/java/io/flutter/plugins/pathprovider/PathProviderPlugin.java"

# Find the actual file path
ACTUAL_PATH=$(find "$HOME/.pub-cache/hosted/pub.dev" -name "PathProviderPlugin.java" -path "*/pathprovider/*" 2>/dev/null | head -1)

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

echo "Fixing path_provider_android plugin V1 embedding compatibility..."

# Create a backup
cp "$ACTUAL_PATH" "${ACTUAL_PATH}.bak"

# Remove the registerWith method
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS sed
    # Remove registerWith method (from @SuppressWarnings to closing brace)
    sed -i.bak2 '/@SuppressWarnings("deprecation")/,/^  }$/{
        /public static void registerWith/,/^  }$/d
    }' "$ACTUAL_PATH"
    
    # Remove comment if it exists
    sed -i.bak3 '/Removed registerWith method/d' "$ACTUAL_PATH"
    
    # Clean up backup files
    rm -f "${ACTUAL_PATH}.bak" "${ACTUAL_PATH}.bak2" "${ACTUAL_PATH}.bak3" 2>/dev/null
else
    # Linux sed
    sed -i '/@SuppressWarnings("deprecation")/,/^  }$/{
        /public static void registerWith/,/^  }$/d
    }' "$ACTUAL_PATH"
    
    sed -i '/Removed registerWith method/d' "$ACTUAL_PATH"
fi

echo "  ✓ Fixed path_provider_android plugin V1 embedding compatibility"
