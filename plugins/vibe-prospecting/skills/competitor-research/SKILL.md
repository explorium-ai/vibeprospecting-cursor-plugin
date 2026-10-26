---
name: competitor-research
description: "Compare two to four rival companies side by side: size, funding, hiring trends, tech stack, recent strategic moves, and overlap with the user's target customers, with a short battlecard per competitor. Use for 'compare Gong and Chorus', 'size up our competitors', 'competitive landscape for X', 'battlecard for renewal'. Not for a deep brief on one company (use account-research) or for finding lookalike companies (use lookalike-accounts)."
---

# Competitor Research

A dated, fact-led comparison of a few named rivals.

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

- **Competitors** (required): 2-4 names or domains. Four is the practical limit, because `show-sample` reveals 5 rows.
- **Purpose** (ask once if missing): battlecard, board update, win-loss prep, renewal.
- Optional: priority angles (pricing pressure, AI roadmap, a region), the user's target customers (to judge overlap), and hypotheses to confirm or contradict.

## Workflow

1. **Anchor.** Restate the purpose, angles and hypotheses in 1-2 sentences.
2. **Match all competitors** in one `match-business` call, with name and domain where available. Check each for the shell-entity pattern (a big brand showing 1-50 employees under "Corporate Managing Offices") and retry with the alternate domain. Drop and flag any that do not resolve confidently; do not proceed with the wrong company.
3. **Enrich** the matched table, at most 3 types per call, each on the latest `table_name`: firmographics, funding-and-acquisitions, workforce-trends, technographics, competitive-landscape, strategic-insights, challenges, company-ratings, linkedin-posts. Prioritize by the user's angles, and say which were skipped.
4. **Fetch events** with `fetch-businesses-events` for the last 90 days. Keep launches (`new_product`), funding (`new_funding_round`), `merger_and_acquisitions`, `new_office` and `closing_office`, `cost_cutting`, partnerships, and notable department hiring or cuts. Before using an event, check that it names the competitor.
5. **Show** with `show-sample` on the enriched table and on the events table.
6. **Judge overlap** per competitor (High, Partial, None) against the user's stated target customers, using firmographics. If none were given, write "Not assessed".
7. **Check each hypothesis** as confirmed, contradicted or unresolved, citing the data point behind the call.

## Reply

- **Purpose and hypothesis check** in two or three lines.
- **Side-by-side table:** company, domain, HQ, headcount bucket, revenue bucket, founded, public or private, latest funding, latest dated move.
- **Per competitor:** snapshot, recent moves (dated), positioning in the company's own terms from strategic-insights or competitive-landscape, workforce direction, challenges, overlap, and three discovery questions rooted in specific facts.
- **Data quality:** unresolved names, empty enrichments, stale records, contradictions.
- Offer `account-contacts` to map the buying committee at a specific account, or the export if the user wants the data.

## Limitations

- Challenges, strategy and competitive landscape come from public filings: empty for private rivals and 12-18 months old for public ones. For private companies lean on funding, events, workforce trends, tech stack and posts.
- Headcount and revenue are buckets; compare buckets, not numbers.
- Review-site sentiment (G2, TrustRadius) and earnings-call content are not in the data.
- No similar-companies model. For rivals beyond the named ones, use `lookalike-accounts` or the competitive-landscape results, and label them as approximations.
