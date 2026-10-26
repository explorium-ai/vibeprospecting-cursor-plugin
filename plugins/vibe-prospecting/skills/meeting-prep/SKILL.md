---
name: meeting-prep
description: "Prepare a 30-minute call brief for a target account: headline signals, attendee profiles, ranked talking points, discovery questions, a suggested agenda, and what to avoid. Use for 'prep me for a call with Acme', 'I have a meeting with Jane at Globex tomorrow', 'pre-meeting research', renewal or QBR meetings. Not for general research with no meeting (use account-research) or for a standalone person lookup (use enrich-contact)."
---

# Meeting Prep

Gather the company, signal and attendee evidence, then write a tight brief the user can read in five minutes.

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

- **Account** (required): a company name or domain.
- **Attendees** (recommended): names with the company, or emails. Without them the brief stays generic.
- **Meeting context** (strongly recommended): purpose, stakes, deal stage, what the user wants to walk out with, known tensions, competitors, what they are selling, and hypotheses to test. If it is missing, ask once; otherwise prepare general notes and say so.

## Workflow

1. **Anchor.** Restate the purpose and desired outcome in 1-2 sentences and pick 3-5 priority topics and any hypotheses.
2. **Match the company** with `match-business`, checking for the shell-entity pattern (big brand, 1-50 employees, "Corporate Managing Offices") and retrying with the alternate domain.
3. **Enrich the company,** at most 3 types per call, each on the latest `table_name`: firmographics and technographics, funding-and-acquisitions, strategic-insights and challenges, workforce-trends, competitive-landscape and company-hierarchies, linkedin-posts and website-changes. Gather broadly now; decide what matters at the writing step.
4. **Fetch events** with `fetch-businesses-events` on a 30-90 day window. Keep only events that name this company and tie to the meeting.
5. **Match the attendees** with `match-prospects`, by email when known, otherwise full name plus company (add the `business_id`). Report anyone who does not match; never invent their role. Enrich matched people with `enrich-prospects-profiles` for title, tenure and prior roles. Add `enrich-prospects-contacts` only if the user wants to reach out, with `contact_types` set to `["email"]` unless phone is needed.
6. **Show** with `show-sample` on the company table, the events table and the attendee table. Real values reach you only through these calls.
7. **Write the brief,** then the TL;DR last. Choose what matters for this meeting, drop generic press, and mark past-dated milestones "verify". Describe engagement or objections only when the user supplied direct interaction evidence. Without it, write 'Engagement unknown'; tenure, prior employers and public company activity do not establish an attendee's attitude toward the user or offering.

## Reply

- **TL;DR:** purpose and desired outcome, the top 3 things to know, a one-line check of each hypothesis (confirmed, contradicted, unresolved), and a suggested opening line.
- **Company snapshot:** industry, size bucket, revenue bucket, HQ, and one paragraph on strategy and challenges.
- **Signals worth raising,** grouped by funding, hiring, tech stack, events, voice and competitors.
- **Attendees:** name, title, department ("Unattributed" if empty), seniority, tenure, contact details if enriched, engagement evidence or "Engagement unknown", why they matter for this meeting, and 1-2 specific talking points. "Profile data limited; verify elsewhere" when thin.
- **Talking points (3-5)** and **discovery questions (3-5),** each tied to a specific fact.
- **Suggested agenda (30 minutes):** open, explore, develop, close on a specific next step.
- **What not to do:** 1-3 concrete failure modes for this meeting.

## Limitations

- Strategy and challenge data come from public filings: empty for private companies and 12-18 months old for public ones.
- No CRM history or deal-stage data; engagement status depends on direct interaction evidence supplied by the user, not profile or public company activity.
- No executive-move event type; infer leadership changes from workforce trends and profiles.
- Size and revenue are buckets; quote them as such.
- Attendees who cannot be matched stay unresolved.
