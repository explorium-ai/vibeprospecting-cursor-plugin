# Vibe Prospecting Cursor Plugin

<img src="plugins/vibe-prospecting/assets/logo.png" width="48" height="48" alt="Vibe Prospecting" />

**Find company & contact data.**

Turn your Cursor agent into a prospecting platform. Find any company or professional right in your Cursor. Get contact information, roles, tech stack, business events, website changes, intent data, and much more. Build lead lists, research prospects, identify talent, and craft personalized outreach, all without leaving your chat.

Vibe Prospecting delivers fresh B2B data backed by 50+ data sources. Vibe Prospecting has 150M+ companies and 800M+ professionals, with verified contact information, firmographics, technographics, hiring trends, intent signals, funding events, and more.

**Developed by:** [Vibeprospecting.ai](https://vibeprospecting.ai)

## Features

- Build lead lists and research prospects without leaving chat
- Find companies by industry, size, tech stack, location, or buying intent
- Find prospects by job title, department, company, or location
- Enrich with firmographics, technographics, contacts, and events
- Export results to CSV

## Prerequisites

- Cursor IDE v1.0 or later (for OAuth support with the remote MCP server)

## Installation

1. Clone or add this repository to your Cursor workspace.
2. The plugin registers itself via `.cursor-plugin/marketplace.json`.
3. Connect to the Vibe Prospecting MCP server when prompted (OAuth flow).

## Connecting locally

Cursor does not auto-discover plugins from a workspace's `marketplace.json`. To see Vibe Prospecting in Settings > Plugins, run the install script:

```bash
./scripts/install-plugin.sh
```

Then **restart Cursor** (Cmd+Q, then reopen). The plugin will appear in Settings > Plugins under "Installed".

If the plugin still doesn't load, enable **"Include third-party Plugins, Skills, and other configs"** in Settings > Features.

**MCP connection**: When you use the agent with a prospecting request, Cursor connects to `https://mcp-cursor.vibeprospecting.ai/mcp`. On first use, you'll be prompted to authenticate via OAuth in your browser.

## MCP Server

- **Connector URL:** `https://mcp-cursor.vibeprospecting.ai/mcp`
- OAuth authentication. Cursor handles the flow automatically when you first use the plugin.

## Validation

Run validation before committing:

```bash
node scripts/validate-template.mjs
```
