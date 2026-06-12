# MuleSoft Demo Builder Plugin - Installation Guide

**Created by**: Vasif Shaikh (Integration Boutique)  
**Contact**: connect@integrationboutique.com  
**Version**: 1.0.0

---

## What is This?

The **MuleSoft Demo Builder** is a comprehensive Claude Code skill that helps you create impressive, working MuleSoft integration demos with:

- ✅ RAML API specifications
- ✅ Exchange connectors (not generic HTTP)
- ✅ Full drag-and-drop metadata
- ✅ Interactive web pages
- ✅ Realistic mock data
- ✅ End-to-end working flows

**Philosophy**: "No Vibes, Just Drag & Drop" - make integration look easy!

---

## Installation Instructions

### **Step 1: Extract the Plugin**

```bash
# Create plugin directory
mkdir -p ~/.aisuite/plugins/mulesoft-demo/releases/v1.0.0-local

# Extract archive
cd ~/.aisuite/plugins/mulesoft-demo/releases/v1.0.0-local
tar -xzf ~/path/to/mulesoft-demo-plugin.tar.gz
```

### **Step 2: Create Marketplace Symlinks**

```bash
# Create marketplace plugin directory
mkdir -p ~/.aisuite/marketplaces/aisuite/plugins/mulesoft-demo

# Create symlinks
cd ~/.aisuite/marketplaces/aisuite/plugins/mulesoft-demo
ln -sf ~/.aisuite/plugins/mulesoft-demo/releases/v1.0.0-local/.claude-plugin .claude-plugin
ln -sf ~/.aisuite/plugins/mulesoft-demo/releases/v1.0.0-local/skills skills
```

### **Step 3: Register in Registry**

Edit `~/.aisuite/registry.json` and add this entry in the `"plugins"` section:

```json
"mulesoft-demo": {
  "source": "manual",
  "enabled": true,
  "install": {
    "status": "installed",
    "path": "/Users/YOUR_USERNAME/.aisuite/plugins/mulesoft-demo/releases/v1.0.0-local"
  },
  "env": {},
  "clientLastApplied": {
    "installed": true,
    "enabled": true
  },
  "installedRef": "v1.0.0",
  "name": "Mulesoft Demo"
}
```

**⚠️ Important**: Replace `YOUR_USERNAME` with your actual username!

### **Step 4: Enable in Settings**

Edit `~/.claude/settings.json` and add to the `"enabledPlugins"` section:

```json
"enabledPlugins": {
  ...existing plugins...,
  "mulesoft-demo@aisuite": true
}
```

### **Step 5: Reload Skills**

1. Restart Claude Code completely (quit and reopen)
2. Or run `/reload-skills` in Claude Code
3. Type `/mulesoft` to verify it appears

You should see:
```
/mulesoft-demo:mulesoft-demo-builder
```

---

## How to Use

### **Invoke the Skill:**

```
/mulesoft-demo:mulesoft-demo-builder
```

or just type:

```
Create a MuleSoft demo for employee onboarding
```

### **The Skill Will Ask:**

1. What's the integration scenario?
2. Which 3 systems are involved?
3. Who is the customer/audience?
4. What's the business outcome?

### **Then Guide You Through 7 Phases:**

1. **Planning & Design** (5-10 min)
2. **RAML API Specifications** (15-20 min)
3. **MuleSoft Project Setup** (10 min)
4. **Flow Implementation** (20-30 min)
5. **Metadata Setup** (20-30 min)
6. **Interactive Demo Webpage** (30-40 min)
7. **Testing & Documentation** (15-20 min)

---

## Example Scenarios

- **Employee Lifecycle**: Neogov → NetSuite → TeleStaff
- **Order Processing**: E-commerce → ERP → Warehouse
- **Customer Onboarding**: CRM → Billing → Support
- **Claims Processing**: Claims System → Core → Payment

---

## What Gets Created

The skill creates:
- 📄 RAML specifications for each system
- 🔧 MuleSoft flow XML with Exchange connectors
- 📊 JSON metadata files for drag-and-drop
- 🌐 Interactive HTML demo page with customer branding
- 📚 Complete documentation (README, guides, checklists)
- ✅ Working end-to-end integration

---

## Troubleshooting

### **Skill doesn't appear after `/reload-skills`**

Try:
1. Restart Claude Code completely
2. Verify file structure:
   ```bash
   ls -la ~/.aisuite/plugins/mulesoft-demo/releases/v1.0.0-local/
   # Should show: .claude-plugin/ and skills/
   ```
3. Check registry.json has correct path with your username
4. Verify enabledPlugins in settings.json

### **Permission errors**

Make sure all directories are readable:
```bash
chmod -R 755 ~/.aisuite/plugins/mulesoft-demo
```

### **Symlinks broken**

Recreate symlinks (Step 2 above)

---

## Support

Created by **Vasif Shaikh** @ Integration Boutique  
📧 connect@integrationboutique.com  
🌐 integrationboutique.com

---

## License

Feel free to use, modify, and share within your organization!

**Happy Demo Building! 🚀**
