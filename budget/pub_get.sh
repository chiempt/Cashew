#!/bin/bash
# Wrapper script for flutter pub get that:
# 1. Filters file_picker warnings for unsupported desktop platforms
# 2. Automatically fixes missing namespace in ALL Flutter plugins (AGP 8.x compatibility)

flutter pub get 2>&1 | grep -vE "(file_picker.*references.*as the default plugin|Ask the maintainers of file_picker|add an inline implementation to file_picker)"

# Fix all plugin namespaces after pub get
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/fix_all_plugin_namespaces.sh" 2>/dev/null || true

# Fix V1 embedding compatibility for plugins
"$SCRIPT_DIR/fix_image_picker_v1_embedding.sh" 2>/dev/null || true
"$SCRIPT_DIR/fix_in_app_purchase_v1_embedding.sh" 2>/dev/null || true
"$SCRIPT_DIR/fix_path_provider_v1_embedding.sh" 2>/dev/null || true
"$SCRIPT_DIR/fix_quick_actions_v1_embedding.sh" 2>/dev/null || true
