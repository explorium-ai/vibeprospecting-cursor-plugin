# Vibe Prospecting

<img src="plugins/vibe-prospecting/assets/logo.png" width="48" height="48" alt="Vibe Prospecting" />

Find leads & B2B contact data inside Cursor.

Vibe Prospecting brings live B2B data into Cursor for prospecting, lead research, and data enrichment. It draws on a database of 150M+ companies and 800M+ professional contacts aggregated from 50+ sources, so you can build lead lists, research accounts, and fill in missing contact data without leaving the chat.

**Developed by:** [Explorium.ai](https://vibeprospecting.ai)

## Capabilities

- Turn an ideal customer profile into a targeted list of companies and decision-makers
- Find business emails and phone numbers for named contacts or prospects matching your criteria
- Enrich company and contact records with firmographics, technology data and professional profiles
- Research target accounts and compare competitors using funding, hiring, technology and business signals
- Prioritize accounts and leads against your ICP using available buying intent and recent business events
- Map potential buying-committee roles and prepare meeting briefs from company and attendee research
- Find lookalike companies using a seed account's industry, size, geography and technology profile
- Count companies matching your ICP to estimate market size and refine territory filters
- Source candidates from a role brief and map talent pools across target companies
- Normalize pasted company and contact lists, flag formatting issues and identify matched duplicates

## Files

- `.cursor-plugin/marketplace.json`: marketplace manifest. `pluginRoot` is `plugins` and the plugin `source` is `vibe-prospecting`.
- `plugins/vibe-prospecting/.cursor-plugin/plugin.json`: plugin manifest, version 1.0.1.
- `plugins/vibe-prospecting/mcp.json`: the remote MCP server `vibe-prospecting` at `https://mcp-cursor.vibeprospecting.ai/mcp`.
- `plugins/vibe-prospecting/skills/`: twelve workflow skills, each carrying the same connector rules: `list-builder`, `account-contacts`, `enrich-company`, `enrich-contact`, `account-research`, `competitor-research`, `meeting-prep`, `lookalike-accounts`, `market-sizing`, `score-leads`, `talent-sourcing`, `clean-data`. They mirror the skills in [vibeprospecting-openai-plugin](https://github.com/explorium-ai/vibeprospecting-openai-plugin).
- `plugins/vibe-prospecting/assets/logo.png`: 256x256 plugin icon.

## Installation

Copy `plugins/vibe-prospecting` to `~/.cursor/plugins/local/vibe-prospecting/`, then restart Cursor. The plugin appears in Settings > Plugins.

On first use, Cursor connects to the MCP server and starts the OAuth flow in your browser.

## Try prompts like

- "Find 30 VPs of Engineering based in Texas at SaaS companies."
- "Enrich stripe.com with company size, funding, and technology data."
- "Find 30 senior backend engineers in Berlin with Go experience."

## Links

- [Website](https://www.vibeprospecting.ai)
- [Support](https://www.vibeprospecting.ai/contact-us)
- [Privacy policy](https://www.vibeprospecting.ai/privacy-policy)
- [Terms of service](https://www.vibeprospecting.ai/terms-of-service)
