---
name: account-research
description: "Build a purpose-driven intelligence brief on one target company: firmographics, funding, hiring and workforce trends, tech stack, recent business events, and peers. Use for pre-call research, renewal or QBR prep, competitive evaluation, and outbound targeting, for example 'research stripe.com for outbound to finance leaders', 'account brief on Snowflake', 'profile this company before my call'. Not for a quick lookup of one data point (use enrich-company), a comparison of several rivals (use competitor-research), or a meeting agenda with attendee profiles (use meeting-prep)."
---

# Account Research

A brief on one company, framed around why the user needs it.

## Connector rules

Use only the Vibe Prospecting tools in your tool list. Each tool's live description and input schema are authoritative; if this skill disagrees with a tool, follow the tool.

- **`tool_reasoning`** is required on every call: one short sentence (≤200 characters) that paraphrases what the user wants. No earlier conversation, contact details, or other personal data.
- **Chaining:** copy `session_id` and `table_name` from the previous tool response; never invent either. After an enrich or events step, use the new `table_name`.
- **`autocomplete` first**, one concept per call, for `linkedin_category`, `naics_category`, `company_tech_stack_tech`, `job_title`, `interests`, `skills`, `business_intent_topics`, and US `city_region`. Use the returned values as-is.
- **What you can see:** `match-business` and `match-prospects` return complete results; fetch, enrich, and events tools return only a masked preview, so never quote values from it; `fetch-entities-statistics` returns aggregates; `show-sample` reveals up to 5 full rows.
- **Finish with `show-sample`**, once per final `table_name`, then reply. Match-only and statistics-only work does not need it. The widget displays the sample rows, so do not repeat them as a table; use them for your analysis. If `display_status` is `masked`, say the full rows could not be revealed.
- **Export** only after the user explicitly confirms, because it consumes credits. Show the returned download `url`. Never mention table names or session IDs to the user.
- **Uploads:** you cannot upload files to Vibe Prospecting. Pasted lists and text from attached files are fine to use. If the user asks how to upload a list, point them to the Vibe Prospecting Hub: https://app.vibeprospecting.ai/lists

## Input

- **Company** (required): a name or domain.
- **Purpose** (strongly recommended): one sentence on why the brief is needed and what decision it supports (renewal risk, competitive evaluation against Acme, outbound to finance leaders). If it is missing, ask once; if the user declines, produce general account intelligence and say so.

## Workflow

1. **Anchor on purpose.** Restate it in one sentence and pick 2-4 themes (for renewal risk: workforce changes, executive moves, competing vendors, expansion signals). Themes decide which enrichments to add and how to filter peers.
2. **Match the company** with `match-business` using name and domain. A major brand that resolves to 1-50 employees in "Corporate Managing Offices" is likely a shell entity; retry with the other domain or the plain name. If there is no confident match, ask the user.
3. **Enrich in tiers**, at most 3 types per `enrich-business` call, each on the latest `table_name`:
   - *Always:* `enrich-business-firmographics`, `enrich-business-company-hierarchies`, `enrich-business-funding-and-acquisitions`, `enrich-business-workforce-trends`, `enrich-business-linkedin-posts`.
   - *By purpose:* competitive evaluation adds technographics, webstack and competitive-landscape; renewal or QBR adds company-ratings, challenges and strategic-insights; outbound adds website-changes and website-keywords (keywords tied to the user's offering); investor or M&A adds financial-metrics (needs a `date`).
   - *Skip* the rest unless the purpose calls for them. Any enrichment that is skipped or empty gets a one-line note in its section so the reader can tell "not investigated" from "no data".
4. **Fetch business events** with `fetch-businesses-events` for the last 90 days. Useful types: `new_funding_round`, `new_product`, `new_partnership`, `new_office`, `closing_office`, `cost_cutting`, `merger_and_acquisitions`, `outages_and_security_breaches`, and the `hiring_in_*`, `increase_in_*` and `decrease_in_*` department types. Use `employee_joined_company` as a rough signal for leadership hires. Before quoting an event, confirm it actually names the target: industry-wide stories can be attributed to several companies.
5. **Peer set (directional, up to 5).** Derive a sub-category from the purpose, not from a broad industry label: for "vs Databricks", the data-platform sub-vertical; for outbound to finance leaders, the target's go-to-market sub-vertical. Run `fetch-entities` for businesses with those filters and include any competitor the user named, labeled "named by user". If fewer than 3 solid peers come back, skip the section and say so.
6. **Show:** `show-sample` on the enriched company table, on the events table, and on the peer table. Real values reach you only through these calls.
7. **Reconcile, then write.** If an event shows a newer funding round than the funding enrichment, trust the event and flag the lag. For public companies, add a one-line financial posture marked "verify". Mark past-dated milestones "verify". Cross-check signals (a new CTO plus a webstack change plus engineering hiring is a timing signal). Write the summary last.

## Reply

- **TL;DR:** the purpose, a 2-4 sentence "why now", the 3 most consequential facts, and 1-3 specific actions.
- **Snapshot:** domain, industry, headcount and revenue buckets, HQ, public or private, founded.
- **Sections:** funding and capital, workforce and hiring, tech stack and website activity, challenges and strategy, recent events (dated, grouped when there are four or more), peers. Skip sections with no data and say why.
- **Next steps:** actions tied to a named signal or person. Offer `account-contacts` for the people to contact and `meeting-prep` if a call is scheduled.

## Limitations

- Challenges, strategy and competitive landscape come from public filings: empty for private companies and 12-18 months old for public ones.
- No similar-companies model; peers are approximated from filters and are directional only.
- No executive-move event type. Leadership changes must be inferred from `employee_joined_company`, hiring events and posts, and flagged as inferred.
- Headcount and revenue are buckets.
- Matching returns no confidence score.
