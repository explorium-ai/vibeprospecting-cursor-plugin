---
name: talent-sourcing
description: "Source candidates from a job description or role brief, or map the talent bench for a function across target or competitor companies with movement signals such as layoffs and leadership changes. Use for 'find candidates for a senior Go engineer in Berlin', 'build a talent pipeline for a VP Sales', 'who could fill this role', 'map the data engineering teams at our competitors', 'where can we hire from'. Recruiting and talent intelligence only. Not for sales prospecting (use list-builder) or for researching a named person (use enrich-contact)."
---

# Talent Sourcing

Turn a role brief into a candidate search, or map where a function's talent sits across companies.

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

- **Pipeline:** the user has a role to fill and wants candidates.
- **Bench map:** the user wants to see who does a function across a set of companies and where talent may be open to a move.

## Fair-hiring and privacy rules

- Never filter, score or comment on protected characteristics (age, gender, ethnicity, religion, disability, nationality, family status) or on proxies for them, such as graduation year to infer age or a name to infer gender or origin. If the brief asks for that, decline that criterion and say why.
- Use only job-related evidence that the data shows. Mark a skill the profile does not show as "unverified" instead of inferring it.
- Use contact data only for recruiting outreach about a real role, and remind the user to honor opt-outs and local rules (GDPR, CCPA).
- Do not pull personal contact data during a bench map.

## Pipeline mode

### Input

Role (title, seniority, function); must-haves and nice-to-haves (propose a split and confirm if the brief does not separate them); the source-company profile or named target companies; exclusions (current employer, no-poach clients); geography; the number wanted (default 30, up to 150).

### Workflow

1. **Blueprint.** Translate the brief into a candidate profile and a source-company profile. Expand the title into 3-6 adjacent titles a strong candidate might hold today, and note a step-up pool one level below if the role is a promotion for most people. Show the blueprint and confirm before searching.
2. **Resolve values** with `autocomplete` for titles, skills, interests, industries and technologies.
3. **Source companies.** For named companies, `match-business` and check for shell entities; for a company profile, set the company filters directly on the prospect search. Drop excluded companies using `business_id` with `negate: true`.
4. **Encode the must-haves as filters:** titles with `job_title` plus `job_level` and `job_department`, location, `skills` or `interests` where the brief names them, `total_experience_months`, and `current_role_months` for tenure (candidates 2-4 years into a role are often the most movable; under 12 months rarely are). Title filters are loose, so pair every title with seniority.
5. **Fetch** with one `fetch-entities` call for prospects at the requested count. If the pool is very large or tiny, check it with `fetch-entities-statistics` first and suggest tightening or broadening. Add `enrich-prospects-profiles` for work history, tenure and prior employers. Add contact enrichment only once the user is ready to reach out, with `contact_types` as the user chooses.
6. **Movement signals,** if asked: `fetch-businesses-events` on the source companies for `cost_cutting`, `merger_and_acquisitions`, `decrease_in_*_department` and `new_funding_round`, and `fetch-prospects-events` for recent role changes. Someone who changed jobs in the last six months is rarely movable; mark them, do not drop them.
7. **Show** with `show-sample`. It reveals 5 rows, so the filters, not your reading, do the matching; describe the rest from counts. To rank every candidate, the user must export first, and you then read the rows with `load-dataset` and `load_into: "context"`. If they do, score each 0-100: must-have fit 50 (a missing must-have caps at 49), nice-to-have fit 20, movability 20, reachability 10.

### Reply

Role blueprint as confirmed; the candidates shown (name, current title, employer, tenure, location, why they fit in one clause); pool read (matching count, any must-have the data cannot evidence, thin geographies); the first people to contact and a specific angle drawn from their trajectory; and next steps (contact enrichment, export, step-up pool, bench map of the best source companies).

## Bench map mode

### Input

A function (required), a company set (named, or a profile capped at 15 companies), optional seniority focus (default Manager and above plus senior individual contributors), geography, and depth: overview (default) or named leaders.

### Workflow

1. **Resolve the companies** with `match-business`, checking for shell entities. If a profile matches more than 15 companies, ask the user to tighten it.
2. **Define the function** as a department plus 4-8 discovered titles across the ladder (individual contributor to C-level). Confirm, since "data" alone can mean analytics, engineering or science.
3. **Count per company** with `fetch-entities-statistics` (`entity_type: prospects`, `business_id` for that company, the department and level filters). Read the aggregates.
4. **Name leaders** only for "named leaders" depth: `fetch-entities` for Directors and above in the function across the set, then `show-sample`. It reveals 5 rows; for a full roster, offer the export. Skip contact enrichment.
5. **Signals,** last 180 days: `fetch-businesses-events` for `cost_cutting`, `merger_and_acquisitions`, `closing_office`, `decrease_in_*_department`, `new_funding_round`; `enrich-business-workforce-trends` for headcount direction; `fetch-prospects-events` for role changes among leaders. Check each event names the company.
6. **Rate each company as a talent source:** bench depth (35: counts relative to the other companies), movement pressure (40: layoff or restructuring 90-100, new function leadership in the last six months 70-85, acquisition 70, declining headcount 50-70, flat 30, strong growth or a fresh large round 10-20), and tenure ripeness (25: the share 2-4 years into role, if you can see it). Do not score individuals here.

### Reply

Map scope (function, titles, levels, companies, any that failed to resolve); a ranking table (company, bench size, directors and above, headcount trend, key signal, source score, why); a short block per company; a market read (deepest benches, most pressure now, feeder companies); and next steps (pipeline mode on the top three, re-run in 60-90 days, `lookalike-accounts` seeded on the best source).

## Limitations

- Profiles show what people publish: skills, scope and team size are often missing, so absence means unknown.
- No skills or certification filter beyond `skills` and `interests` autocomplete values.
- No sub-department function filter; use department plus discovered titles.
- No executive-departure event type; leavers show up only indirectly.
- Headcount and revenue are buckets, so company-size cuts are approximate.
- Compensation, visa status and willingness to move are not available.
- Large companies can return thousands of matches; the map relies on counts beyond what you can read.
