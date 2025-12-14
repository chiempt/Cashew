#!/bin/bash
# Script to fix image_picker_android plugin V1 embedding compatibility issue
# Removes deprecated registerWith method and updates setup method for V2 embedding only

IMAGE_PICKER_PLUGIN_PATH="$HOME/.pub-cache/hosted/pub.dev/image_picker_android-*/android/src/main/java/io/flutter/plugins/imagepicker/ImagePickerPlugin.java"

# Find the actual file path
ACTUAL_PATH=$(find "$HOME/.pub-cache/hosted/pub.dev" -name "ImagePickerPlugin.java" -path "*/imagepicker/*" 2>/dev/null | head -1)

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

echo "Fixing image_picker_android plugin V1 embedding compatibility..."

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
    
    # Change PluginRegistry.Registrar to Object in ActivityState constructor
    sed -i.bak4 's/final PluginRegistry\.Registrar registrar/final Object registrar/g' "$ACTUAL_PATH"
    
    # Change PluginRegistry.Registrar to Object in setup method
    sed -i.bak5 's/final PluginRegistry\.Registrar registrar/final Object registrar/g' "$ACTUAL_PATH"
    
    # Simplify ActivityState constructor to only use V2 embedding
    sed -i.bak6 '/if (registrar != null) {/,/^      }$/{
        /if (registrar != null) {/d
        /V1 embedding setup/,/registrar\.addRequestPermissionsResultListener/d
        /^      } else {/d
        /V2 embedding setup/d
    }' "$ACTUAL_PATH"
    
    # Remove PluginRegistry import if no longer used
    if ! grep -q "PluginRegistry" "$ACTUAL_PATH" 2>/dev/null; then
        sed -i.bak7 '/import io\.flutter\.plugin\.common\.PluginRegistry;/d' "$ACTUAL_PATH"
    fi
    
    # Clean up backup files
    rm -f "${ACTUAL_PATH}.bak" "${ACTUAL_PATH}.bak2" "${ACTUAL_PATH}.bak3" "${ACTUAL_PATH}.bak4" "${ACTUAL_PATH}.bak5" "${ACTUAL_PATH}.bak6" "${ACTUAL_PATH}.bak7" 2>/dev/null
else
    # Linux sed
    sed -i '/@SuppressWarnings("deprecation")/,/^  }$/{
        /public static void registerWith/,/^  }$/d
    }' "$ACTUAL_PATH"
    
    sed -i '/Removed registerWith method/d' "$ACTUAL_PATH"
    sed -i 's/final PluginRegistry\.Registrar registrar/final Object registrar/g' "$ACTUAL_PATH"
    sed -i '/if (registrar != null) {/,/^      }$/{
        /if (registrar != null) {/d
        /V1 embedding setup/,/registrar\.addRequestPermissionsResultListener/d
        /^      } else {/d
        /V2 embedding setup/d
    }' "$ACTUAL_PATH"
    
    if ! grep -q "PluginRegistry" "$ACTUAL_PATH" 2>/dev/null; then
        sed -i '/import io\.flutter\.plugin\.common\.PluginRegistry;/d' "$ACTUAL_PATH"
    fi
fi

echo "  ✓ Fixed image_picker_android plugin V1 embedding compatibility"
