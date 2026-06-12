#!/bin/bash

# MuleSoft Demo Builder Plugin - Auto Installer
# Created by: Vasif Shaikh (Integration Boutique)

set -e

echo "🚀 Installing MuleSoft Demo Builder Plugin..."
echo ""

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ARCHIVE="$SCRIPT_DIR/mulesoft-demo-plugin.tar.gz"

# Check if archive exists
if [ ! -f "$ARCHIVE" ]; then
    echo "❌ Error: mulesoft-demo-plugin.tar.gz not found in $SCRIPT_DIR"
    echo "Please make sure the archive is in the same directory as this script."
    exit 1
fi

# Step 1: Extract plugin
echo "📦 Step 1/5: Extracting plugin files..."
mkdir -p ~/.aisuite/plugins/mulesoft-demo/releases/v1.0.0-local
cd ~/.aisuite/plugins/mulesoft-demo/releases/v1.0.0-local
tar -xzf "$ARCHIVE"
echo "   ✅ Extracted"

# Step 2: Create marketplace symlinks
echo "🔗 Step 2/5: Creating marketplace symlinks..."
mkdir -p ~/.aisuite/marketplaces/aisuite/plugins/mulesoft-demo
cd ~/.aisuite/marketplaces/aisuite/plugins/mulesoft-demo
ln -sf ~/.aisuite/plugins/mulesoft-demo/releases/v1.0.0-local/.claude-plugin .claude-plugin
ln -sf ~/.aisuite/plugins/mulesoft-demo/releases/v1.0.0-local/skills skills
echo "   ✅ Symlinks created"

# Step 3: Update registry.json
echo "📝 Step 3/5: Updating registry.json..."
REGISTRY_FILE=~/.aisuite/registry.json

if [ ! -f "$REGISTRY_FILE" ]; then
    echo "   ⚠️  Warning: registry.json not found. You'll need to add it manually."
else
    # Create backup
    cp "$REGISTRY_FILE" "$REGISTRY_FILE.backup"

    # Check if plugin already exists
    if grep -q '"mulesoft-demo"' "$REGISTRY_FILE"; then
        echo "   ℹ️  Plugin entry already exists in registry.json"
    else
        echo "   ⚠️  Please manually add the plugin entry to registry.json"
        echo "      See installation guide for details"
    fi
fi

# Step 4: Update settings.json
echo "🔧 Step 4/5: Checking settings.json..."
SETTINGS_FILE=~/.claude/settings.json

if [ ! -f "$SETTINGS_FILE" ]; then
    echo "   ⚠️  Warning: settings.json not found at ~/.claude/settings.json"
else
    if grep -q '"mulesoft-demo@aisuite"' "$SETTINGS_FILE"; then
        echo "   ✅ Plugin already enabled in settings.json"
    else
        echo "   ⚠️  Please manually add to enabledPlugins in settings.json:"
        echo '      "mulesoft-demo@aisuite": true'
    fi
fi

# Step 5: Verify installation
echo "✅ Step 5/5: Verifying installation..."
if [ -f ~/.aisuite/plugins/mulesoft-demo/releases/v1.0.0-local/skills/mulesoft-demo-builder/SKILL.md ]; then
    echo "   ✅ SKILL.md found"
fi
if [ -f ~/.aisuite/plugins/mulesoft-demo/releases/v1.0.0-local/.claude-plugin/plugin.json ]; then
    echo "   ✅ plugin.json found"
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "📋 Next Steps:"
echo "   1. Manually update ~/.aisuite/registry.json (see INSTALL.md)"
echo "   2. Manually update ~/.claude/settings.json (see INSTALL.md)"
echo "   3. Restart Claude Code"
echo "   4. Run /reload-skills"
echo "   5. Type /mulesoft to verify"
echo ""
echo "📖 See mulesoft-demo-plugin-INSTALL.md for detailed instructions"
echo ""
echo "✨ Happy Demo Building!"
