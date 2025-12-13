#!/bin/bash
# Fix for Xcode 26: Remove unsupported -G flag from compiler flags
# This script patches build settings to remove -G flag during build

set -e

# Remove -G flag from environment variables that might be passed to compiler
export CC="${CC/-G / }"
export CXX="${CXX/-G / }"
export CFLAGS="${CFLAGS/-G / }"
export CXXFLAGS="${CXXFLAGS/-G / }"
export LDFLAGS="${LDFLAGS/-G / }"

# Also patch xcconfig files if they exist
if [ -d "${SRCROOT}/Pods/Target Support Files" ]; then
    find "${SRCROOT}/Pods/Target Support Files" -name "*.xcconfig" -type f | while read config_file; do
        if grep -qE "\b-G\b" "$config_file" 2>/dev/null; then
            sed -i '' 's/\b-G\b[[:space:]]*//g' "$config_file" 2>/dev/null || true
            sed -i '' 's/[[:space:]]*\b-G\b//g' "$config_file" 2>/dev/null || true
        fi
    done
fi

echo "Fixed -G flag issue for Xcode 26"

