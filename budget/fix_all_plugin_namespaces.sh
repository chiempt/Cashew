#!/bin/bash
# Script to automatically fix missing namespace in ALL Flutter plugins
# Required for AGP 8.x compatibility
# This script scans all plugins in pub cache and adds namespace if missing

echo "Fixing missing namespaces in Flutter plugins for AGP 8.x compatibility..."

# Function to fix namespace for a single plugin
fix_plugin_namespace() {
    local BUILD_GRADLE="$1"
    local PLUGIN_DIR=$(dirname "$BUILD_GRADLE")
    
    # Skip if namespace already exists
    if grep -q "^\s*namespace\s" "$BUILD_GRADLE"; then
        return 0
    fi
    
    # Try to find AndroidManifest.xml in common locations
    local MANIFEST_PATHS=(
        "$PLUGIN_DIR/src/main/AndroidManifest.xml"
        "$PLUGIN_DIR/src/android/AndroidManifest.xml"
        "$PLUGIN_DIR/AndroidManifest.xml"
    )
    
    local MANIFEST_PATH=""
    for path in "${MANIFEST_PATHS[@]}"; do
        if [ -f "$path" ]; then
            MANIFEST_PATH="$path"
            break
        fi
    done
    
    if [ -z "$MANIFEST_PATH" ]; then
        return 0
    fi
    
    # Extract package name from AndroidManifest.xml
    local PACKAGE_NAME=$(grep 'package=' "$MANIFEST_PATH" | sed -n 's/.*package="\([^"]*\)".*/\1/p' | head -1)
    
    if [ -z "$PACKAGE_NAME" ]; then
        return 0
    fi
    
    # Check if android block exists
    if ! grep -q "^android {" "$BUILD_GRADLE"; then
        return 0
    fi
    
    # Add namespace after android { line
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS sed
        sed -i.bak "/^android {/a\\
    namespace '$PACKAGE_NAME'
" "$BUILD_GRADLE"
    else
        # Linux sed
        sed -i "/^android {/a\    namespace '$PACKAGE_NAME'" "$BUILD_GRADLE"
    fi
    
    # Remove backup file if created
    [ -f "${BUILD_GRADLE}.bak" ] && rm -f "${BUILD_GRADLE}.bak"
    
    local PLUGIN_NAME=$(basename "$(dirname "$PLUGIN_DIR")")
    echo "  ✓ Added namespace '$PACKAGE_NAME' to $PLUGIN_NAME"
    
    return 0
}

# Find all build.gradle files in pub cache (hosted packages)
FIXED_COUNT=0
while IFS= read -r -d '' BUILD_GRADLE; do
    # Skip example projects
    if [[ "$BUILD_GRADLE" == *"/example/"* ]]; then
        continue
    fi
    
    # Only process android/build.gradle files
    if [[ "$BUILD_GRADLE" == */android/build.gradle ]]; then
        if fix_plugin_namespace "$BUILD_GRADLE"; then
            ((FIXED_COUNT++))
        fi
    fi
done < <(find "$HOME/.pub-cache/hosted/pub.dev" -name "build.gradle" -type f -print0 2>/dev/null)

# Also check git-based packages
if [ -d "$HOME/.pub-cache/git" ]; then
    while IFS= read -r -d '' BUILD_GRADLE; do
        if [[ "$BUILD_GRADLE" == */android/build.gradle ]]; then
            if fix_plugin_namespace "$BUILD_GRADLE"; then
                ((FIXED_COUNT++))
            fi
        fi
    done < <(find "$HOME/.pub-cache/git" -name "build.gradle" -type f -print0 2>/dev/null)
fi

if [ $FIXED_COUNT -eq 0 ]; then
    echo "No plugins needed namespace fixes."
else
    echo "Fixed namespace in $FIXED_COUNT plugin(s)."
fi
