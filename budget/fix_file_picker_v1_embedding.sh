#!/bin/bash
# Script to fix file_picker plugin V1 embedding compatibility issue
# Removes deprecated registerWith method and updates setup method for V2 embedding only

FILE_PICKER_PLUGIN_PATH="$HOME/.pub-cache/git/flutter_file_picker-*/android/src/main/java/com/mr/flutter/plugin/filepicker/FilePickerPlugin.java"

# Find the actual file path
ACTUAL_PATH=$(find "$HOME/.pub-cache/git" -name "FilePickerPlugin.java" -path "*/filepicker/*" 2>/dev/null | head -1)

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

echo "Fixing file_picker plugin V1 embedding compatibility..."

# Create a backup
cp "$ACTUAL_PATH" "${ACTUAL_PATH}.bak"

# Remove the registerWith method (lines with the method definition and body)
# This is a complex operation, so we'll use sed to remove the method block
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS sed
    sed -i.bak2 '/\/\*\*/,/^    }$/{
        /public static void registerWith/,/^    }$/d
    }' "$ACTUAL_PATH"
    
    # Remove the comment block before registerWith if it exists
    sed -i.bak3 '/Plugin registration/,/^$/d' "$ACTUAL_PATH"
    
    # Change PluginRegistry.Registrar to Object in setup method
    sed -i.bak4 's/final PluginRegistry\.Registrar registrar/final Object registrar/g' "$ACTUAL_PATH"
    
    # Simplify setup method to only use V2 embedding
    sed -i.bak5 '/if (registrar != null) {/,/^        }$/{
        /if (registrar != null) {/d
        /V1 embedding setup/,/registrar\.addRequestPermissionsResultListener/d
        /^        } else {/d
        /V2 embedding setup/d
    }' "$ACTUAL_PATH"
    
    # Clean up backup files
    rm -f "${ACTUAL_PATH}.bak" "${ACTUAL_PATH}.bak2" "${ACTUAL_PATH}.bak3" "${ACTUAL_PATH}.bak4" "${ACTUAL_PATH}.bak5" 2>/dev/null
else
    # Linux sed
    sed -i '/\/\*\*/,/^    }$/{
        /public static void registerWith/,/^    }$/d
    }' "$ACTUAL_PATH"
    
    sed -i '/Plugin registration/,/^$/d' "$ACTUAL_PATH"
    sed -i 's/final PluginRegistry\.Registrar registrar/final Object registrar/g' "$ACTUAL_PATH"
    sed -i '/if (registrar != null) {/,/^        }$/{
        /if (registrar != null) {/d
        /V1 embedding setup/,/registrar\.addRequestPermissionsResultListener/d
        /^        } else {/d
        /V2 embedding setup/d
    }' "$ACTUAL_PATH"
fi

# Remove PluginRegistry import if no longer used
if ! grep -q "PluginRegistry" "$ACTUAL_PATH" 2>/dev/null; then
    sed -i '/import io\.flutter\.plugin\.common\.PluginRegistry;/d' "$ACTUAL_PATH"
fi

echo "  ✓ Fixed file_picker plugin V1 embedding compatibility"
