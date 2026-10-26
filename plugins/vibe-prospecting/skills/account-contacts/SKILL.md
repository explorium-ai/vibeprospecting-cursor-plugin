---
name: account-contacts
description: "Find and rank the right people at one target company: a contact shortlist for outbound, or a buying-committee map showing economic buyers, technical evaluators, influencers and coverage gaps. Use for 'get the HR leadership at miro.com', 'who are the decision-makers at Acme', 'map the buying committee at Globex', 'contacts at Stripe for a security pitch', 'who owns this at the account'. Not for finding people across many companies (use list-builder) or for looking up a named person (use enrich-contact)."
---

# Account Contacts

Pull the right people at one company, check how reachable they are, and say who to engage first.

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

- **Company** (required): a domain (preferred) or a name.
- **Use case:** prospecting (default), deal acceleration, or renewal and expansion. For a buying-committee request, add the purpose: deal stage, who is already engaged, who is missing, and any hypothesis ("find the economic buyer").
- **Focus (optional):** a function (HR, security, finance, RevOps) or seniority (C-level, VP and above, Director and above), and how many people (default 25, up to 100).

If only a bare company is given, ask once what the contacts are for; if the user declines, build a general prospecting shortlist and say so.

## Workflow

1. **Match the company** with `match-business`. A big brand that resolves to 1-50 employees under "Corporate Managing Offices" probably hit a shell entity, so retry with the other domain. If several companies match, show the top 2-3 (industry, size, HQ) and ask.
2. **Turn the use case into a persona blueprint** before fetching:
   - *Prospecting:* broad coverage of the functions that would buy, weighted to Director, VP and C-level.
   - *Deal acceleration:* the economic buyer, a technical evaluator, procurement, and one Director-level champion candidate.
   - *Renewal or expansion:* current product-owner functions plus an executive sponsor, including Manager and Director levels.
   Apply any function or seniority the user named, and say which roles that dropped.
3. **Contact preference.** If the user did not say what contact data they want, ask using the options in the live `fetch-entities` description and set `has_contact_details` from the answer.
4. **Resolve titles.** `autocomplete` for `job_title`. A specific title uses `job_title` (add `job_level` for executives); a broad function uses `job_level` plus `job_department` only. Title filters are loose, so seniority keeps them tight. For "the CFO at Asana", do not try to match a title as a name: filter the company's prospects by title and level.
5. **Fetch** with `fetch-entities` for prospects, scoping to the company with `business_id` and the persona filters, at the requested count. Make one call that covers the whole blueprint. For adjacent functions the user named (procurement, legal, finance), add a second call so coverage gaps are visible.
6. **Enrich** the table: `enrich-prospects-profiles` for tenure and prior roles, and `enrich-prospects-contacts` if the user wants contact data (`contact_types` to match their channel).
7. **Account signals (committee requests):** `fetch-businesses-events` for the last 90 days, because funding, new offices and hiring change who matters. A new joiner is a signal only; there is no executive-move event type. Check that an event names the company before using it.
8. **Show** with `show-sample` on the final table. It reveals 5 rows, so rank and discuss those, and describe the rest from counts and filters. To rank all of a longer list, the user must export first and you then read it with `load-dataset` and `load_into: "context"`; offer it, do not do it unasked.

## Reply

- **Target account:** one line with company, domain, industry, size bucket, revenue bucket, HQ, public or private.
- **Use-case frame:** what the shortlist optimizes for, and any overrides.
- **The people shown:** for each, name, title, seniority, department ("Unattributed" if empty), reachability, and one clause on the role they fill ("VP-level economic buyer in Sales"). The widget displays the rows; keep the table out of your text.
- **Committee map (committee requests):** group by Economic Buyers, Technical Evaluators, Influencers (procurement, legal, operations, adjacent teams) and Potential Champions. Label a Champion only when the user supplied evidence of engagement; title alone is not enough. Mark each user hypothesis confirmed, contradicted or unresolved.
- **Coverage and risk:** gaps where the use case expected a role and nobody turned up, single-thread risk, and who to contact first with a reason each.
- **Next steps:** the export, deeper context with `account-research`, or career-change signals through `fetch-prospects-events` before a first touch.

## Limitations

- No contact data-quality sort; reachability is judged from the contact filter and enriched fields.
- No sub-department function filter; the finest cut is department plus title.
- Company type is only public or private; a subsidiary cannot be told apart from an independent private company.
- Department is empty for many senior cross-functional roles (Chief X Officer, President, Founder): "Unattributed".
- No CRM or engagement data, so champions depend on what the user tells you.
- Executives at well-known companies often have suppressed contact data; suggest LinkedIn.
