# Vibe Prospecting Cursor Plugin

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

## MCP Server

- **Connector URL:** `https://mcp-cursor.vibeprospecting.ai/mcp`
- OAuth authentication. Cursor handles the flow automatically when you first use the plugin.

## Validation

Run validation before committing:

```bash
node scripts/validate-template.mjs
```
