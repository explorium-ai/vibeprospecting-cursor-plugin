---
name: score-leads
description: "Score and tier a list of target accounts (A, B, C by ICP fit, buying intent, recent trigger events and hiring momentum) or a list of people (Hot, Warm, Cold against a buyer persona and ICP), with a one-line 'why now' per row. Use for 'score these accounts', 'rank this list by ICP fit', 'prioritize my leads', 'which of these should I call first', 'tier my inbound leads'. Works on lists pasted in chat. Not for building a new list (use list-builder) or for research on a single company (use account-research)."
---

# Score Leads

Resolve a list, gather evidence for each row, then apply a transparent rubric the user can adjust. The scoring is your reasoning over the returned data; there is no built-in scoring engine.

## Connector rules

Use only the Vibe Prospecting tools in your tool list. Each tool's live description and input schema are authoritative; if this skill disagrees with a tool, follow the tool.

- **`tool_reasoning`** is required on every call: one short sentence (≤200 characters) that paraphrases what the user wants. No earlier conversation, contact details, or other personal data.
- **Chaining:** copy `session_id` and `table_name` from the previous tool response; never invent either. After an enrich or events step, use the new `table_name`.
- **`autocomplete` first**, one concept per call, for `linkedin_category`, `naics_category`, `company_tech_stack_tech`, `job_title`, `interests`, `skills`, `business_intent_topics`, and US `city_region`. Use the returned values as-is.
- **What you can see:** `match-business` and `match-prospects` return complete results; fetch, enrich, and events tools return only a masked preview, so never quote values from it; `fetch-entities-statistics` returns aggregates; `show-sample` reveals up to 5 full rows.
- **Finish with `show-sample`**, once per final `table_name`, then reply. Match-only and statistics-only work does not need it. The widget displays the sample rows, so do not repeat them as a table; use them for your analysis. If `display_status` is `masked`, say the full rows could not be revealed.
- **Export** only after the user explicitly confirms, because it consumes credits. Show the returned download `url`. Never mention table names or session IDs to the user.
- **Uploads:** you cannot upload files to Vibe Prospecting. Pasted lists and text from attached files are fine to use. If the user asks how to upload a list, point them to the Vibe Prospecting Hub: https://app.vibeprospecting.ai/lists

## Choose a mode

- **Accounts:** the list is companies (names, domains). Output is a tier A/B/C with a score per account.
- **People:** the list is leads (emails, LinkedIn URLs, or name plus company). Output is Hot, Warm or Cold per person.

## Input

- **The list** (required), up to 50 accounts or 40 people per match call.
- **ICP** (required): industries, headcount and revenue buckets, countries or regions, optional tech vendors, optional intent topics. For people, also the **buyer persona**: titles, seniority, department.
- **Optional:** a source label per lead (demo request, pricing inquiry, webinar) passed through as given; weights; tier thresholds; trigger window (default 90 days).

If the ICP is missing, ask for it; do not invent one.

## How many rows you can read

Real values reach you only through `show-sample` (up to 5 rows) or, after an export, through `load-dataset` with `load_into: "context"` (up to 50 rows per page, using the export's `dataset_id`). So:

- **Up to 5 rows:** score them directly from `show-sample`.
- **6 to 50 rows:** tell the user you need the full rows to score them, which takes an export that uses credits. Run `export-to-csv` only after they confirm, then read the rows with `load-dataset`.
- **More than 50:** score the first 50 and offer to continue, or export without scoring.

## Workflow

1. **Lock the rubric.** Restate the ICP and persona. Resolve free-text values with `autocomplete`, one term at a time. If an intent topic does not resolve, drop it and mark that axis "not configured" instead of "no intent".
2. **Resolve identities.** Run `match-business` (accounts) or `match-prospects` (people); results are complete, so read them directly.
   - An email is a unique key: a miss is a miss, never a fallback to a name search.
   - A name plus company match at a large company can be ambiguous; mark it "Verified, check".
   - A role without a name ("the CFO at Asana") does not match as a name: match the company, then use `fetch-entities` filtered by title and seniority and let the user pick.
   - Check each resolved company for the shell-entity pattern (a big brand with 1-50 employees under "Corporate Managing Offices") and retry with the alternate domain.
   - Tag each row: resolved, verified-check, ambiguous (ask the user), or failed. Never drop a row silently.
3. **Gather evidence,** at most 3 enrichments per call, each on the latest `table_name`:
   - Accounts: firmographics, technographics, workforce-trends, funding-and-acquisitions, linkedin-posts, website-changes, then `fetch-businesses-events` for the trigger window.
   - People: `enrich-prospects-profiles` (add `enrich-prospects-contacts` if the user wants contact data), `enrich-business-firmographics` for their employer, and `fetch-businesses-events`. For job-change signals, `fetch-prospects-events` (`prospect_changed_role`, `prospect_changed_company`).
   - Intent: a `fetch-entities` scoped with `business_id` values and `business_intent_topics` shows which accounts have the topic.
   Before using an event, check that it names the account; industry-wide stories get attributed to several companies.
4. **Read the rows** as described above.
5. **Score.**
   - *Accounts, 0-100:* default axis weights are Fit 45, Intent 25, Trigger 25, Workforce 5.
     - **Fit:** use only criteria specified in the ICP. Maximum points: industry 25, headcount 20, revenue 20, geography 15, company age 10, named technology 10. Industry earns 25 for a match or 10 for an explicitly accepted adjacent category. Headcount and revenue earn 20 for the requested bucket, 12 for one bucket off, 4 for two off. Geography earns 15 for a match or 8 for an explicitly accepted broader region. Age and technology earn 10 for a match. Other evidenced mismatches earn 0. Exclude unspecified criteria; report missing evidence and exclude that criterion from the denominator. Fit score = 100 times earned points divided by maximum points for the criteria actually assessed. If none can be assessed, Fit is unknown.
     - **Intent:** 90, 70 or 50 for three or more, two or one resolved topics active; 0 only when a completed topic check finds none. Without configured topics or sufficient coverage, mark the axis unknown.
     - **Trigger:** use the strongest returned event. Type score: funding or M&A 95; product launch, hiring surge or large site change 75; partnership or new office 55; generic company news 25. Multiply by recency: 0-14 days 1.0, 15-30 days 0.7, 31-60 days 0.4, 61-90 days 0.2. Use 0 if a completed event query returns no qualifying events; if the query fails or coverage is unknown, mark the axis unknown. Do not infer a CEO change from a generic employee-joined event.
     - **Workforce:** use 90 for evidenced strong growth or a hiring surge in the target department, 55 for modest growth, 20 for flat or shrinking. Cite the returned trend; do not infer exact growth percentages from headcount buckets. Without sufficient evidence, mark the axis unknown.
     - **Total:** sum(axis score times axis weight) divided by sum(available axis weights), rounded to the nearest integer. Report missing axes and assessed fit criteria. If no axes have evidence, leave the score and tier unassigned. Default tiers: A at 75 or more, B at 50-74, C below.
   - *People, three checks:* persona fit (title, seniority, department against the persona), account fit (ICP), and a trigger (account event or a recent role change for them). Hot needs persona fit, account fit and one trigger; Warm needs persona plus either; everything else is Cold. A lead missing both a professional email and a phone gets "verify contact data before outreach".
6. **Write "why now"** as one sentence anchored on the strongest signal, never the score restated. Be explicit when a strong trigger sits on a poor fit ("fresh funding, but the size bucket keeps this in C").

## Reply

- **TL;DR:** counts resolved, ambiguous and failed; the tier distribution; the top 3 with their "why now".
- **Ranked table:** rank, account or person, tier, score or checks, axis detail, why now. Use "-" for a redistributed axis.
- **Resolution summary:** input, resolved to, status; list ambiguous rows with candidates for the user to pick.
- **Rules used:** weights, thresholds, window, and anything redistributed.
- **By tier:** A or Hot for personal outreach within a day; B or Warm for a sequence that opens with the "why now"; C or Cold to watch. Offer to adjust the weights and re-rank without new calls.

## Limitations

- No scoring engine or per-row confidence; the score reflects the data fetched and your reading of it.
- Headcount and revenue are buckets, so banded scoring is the right resolution.
- Filing-based challenge and strategy data is empty for private companies and 12-18 months old for public ones; use events, funding, workforce trends and posts for current state.
- No CRM engagement data (deal stage, last activity); workforce momentum is the substitute and the gap is stated.
- One industry taxonomy and one location level per query.
- Department is empty for many Chief X Officer, President and Founder roles: "Unattributed".
