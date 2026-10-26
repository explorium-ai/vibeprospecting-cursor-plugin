---
name: list-builder
description: "Build a targeted list of companies or people from a plain-language description of the audience: job titles, seniority, department, industry, company size, location, tech stack, buying-intent topics, or recent company events such as funding or a new office. Use for requests like 'find 50 CISOs in Texas', 'companies using Snowflake in the UK', 'build a target account list', 'companies that opened a new office in California', or 'heads of demand gen at fintechs'. Not for a single named company or person (use enrich-company or enrich-contact), for counting a market without pulling rows (use market-sizing), or for sending outreach."
---

# List Builder

Turn a plain-language audience description into a list of companies or people. The user sees a sample in chat and can export the full list.

## Connector rules

Use only the Vibe Prospecting tools in your tool list. Each tool's live description and input schema are authoritative; if this skill disagrees with a tool, follow the tool.

- **`tool_reasoning`** is required on every call: one short sentence (≤200 characters) that paraphrases what the user wants. No earlier conversation, contact details, or other personal data.
- **Chaining:** copy `session_id` and `table_name` from the previous tool response; never invent either. After an enrich or events step, use the new `table_name`.
- **`autocomplete` first**, one concept per call, for `linkedin_category`, `naics_category`, `company_tech_stack_tech`, `job_title`, `interests`, `skills`, `business_intent_topics`, and US `city_region`. Use the returned values as-is.
- **What you can see:** `match-business` and `match-prospects` return complete results; fetch, enrich, and events tools return only a masked preview, so never quote values from it; `fetch-entities-statistics` returns aggregates; `show-sample` reveals up to 5 full rows.
- **Finish with `show-sample`**, once per final `table_name`, then reply. Match-only and statistics-only work does not need it. The widget displays the sample rows, so do not repeat them as a table; use them for your analysis. If `display_status` is `masked`, say the full rows could not be revealed.
- **Export** only after the user explicitly confirms, because it consumes credits. Show the returned download `url`. Never mention table names or session IDs to the user.
- **Uploads:** you cannot upload files to Vibe Prospecting. Pasted lists and text from attached files are fine to use. If the user asks how to upload a list, point them to the Vibe Prospecting Hub: https://app.vibeprospecting.ai/lists

## Parse the request

Pull these out of the user's message:

- **Entity type:** `prospects` if any person attribute is named (title, seniority, department, skills); `businesses` only when the request is about companies with no people.
- **Roles:** titles, seniority, department.
- **Company traits:** industry, size, revenue, company age, public or private.
- **Geography:** country, state or region, US city. Note whether it describes the person or the company.
- **Signals:** tech stack, buying-intent topics, recent events (funding, new office, hiring, M&A) with a 30-90 day window.
- **Count:** use the exact number requested; default 30, maximum 1,000.
- **Extras:** contact details (emails, phones), people per company.

Examples: "100 VP Engineering at Series B SaaS in the US that use Snowflake", "50 CISOs based in TX with 5+ years of experience", "500 companies that opened a new office in CA in the last 90 days", "50 CFOs at public manufacturers that raised funding in the last 90 days".

## Workflow

1. **Ask what is missing, once.** Skip any question the user already answered.
   - *Location (prospects only):* if "in <place>" could mean where the person lives or where the company is headquartered, ask which, or both. Clear wording such as "companies in Germany" or "prospects based in New York" needs no question.
   - *Contact details (prospects only):* unless the user already said what contact data they want, ask using the options in the live `fetch-entities` description, then set `has_contact_details` to match. It filters availability only; it does not return the values.
2. **Resolve values.** Run `autocomplete` for every controlled-vocabulary filter you will use. Use ISO codes directly for countries (`US`) and regions (`US-CA`), and the schema enums for company size, revenue, age, job level and job department.
3. **Build the filters.**
   - **Roles:** broad seniority or department asks ("engineering VPs") use `job_level` plus `job_department` only. A specific title uses `job_title` (from autocomplete); for executive titles add `job_level`. Title filters are loose, so seniority keeps them tight.
   - **One industry taxonomy:** `linkedin_category` or `naics_category`, never both. Start with LinkedIn. Switch to NAICS only if the best LinkedIn match is a parent industry that would pull in many unrelated companies.
   - **One location level per side:** `company_country_code` or `company_region_country_code`; `prospect_country_code` or `prospect_region_country_code`.
   - **Experience:** "5+ years of experience" means `total_experience_months` with `gte: 60`; time in the current role uses `current_role_months`.
   - **Buying intent:** "who needs", "is looking for", "interested in" a product means `business_intent_topics`, with values from autocomplete.
   - **Events:** `events` works for businesses only, with `values` (for example `new_office` for "opened a new office", `new_funding_round`, `new_product`, `merger_and_acquisitions`) and `last_occurrence` of 30-90 days. It selects companies that had the event; it does not add event columns. A completed office-opening event does not establish future office demand. For office-seeking intent, resolve an appropriate intent topic or explain that the requested intent cannot be expressed; do not substitute the event silently.
   - **Ambiguous words** ("designers", "security", "consulting"): offer specific sub-categories and an "all relevant" option, and do not silently pick the broadest.
4. **Fetch once.** Combine everything into a single `fetch-entities` call. Set `max_per_company` only if the user gave a number. Do not call `match-business` or `match-prospects` afterwards, because the IDs are already in the result.
5. **Enrich only on request,** in groups of at most 3 types per call, always on the latest `table_name`. Contact enrichment (`enrich-prospects-contacts`) follows the user's contact answer: set `contact_types` to match the channel they chose. For company details on a prospect table, use `enrich-business`.
6. **Event details:** if the fetch used `events` and the user did not already ask for event details, ask before running `fetch-businesses-events` or `fetch-prospects-events`.
7. **Present:** call `show-sample` on the final `table_name`, then reply in the format below.

## Reply

- **Results Found:** `[key qualifier] [entity type] from [sources]`, with the number of matches if the response gives one.
- **Criteria applied:** a short bullet list of the filters that landed. Say plainly if a request was approximated or could not be expressed.
- **Next steps:** if there is more data than the sample shows, offer the export ("Say 'export' to download all N rows as CSV"); never export without a yes. Add one or two concrete refinements: tighten or widen a bucket, switch location level, add a recent-event filter, pull the people at these companies, add an enrichment.

## Limitations

- Company size and revenue are buckets, not exact figures, and results cannot be sorted by them.
- No metro-area filter: use a US `city_region` or a state or country code.
- No sub-department job-function filter: use the department plus a title.
- No Inc 5000 or Fortune ranking filter; approximate with size, revenue and the public-company flag.
- Contact data arrives only through enrichment. `has_contact_details` filters availability.
- Prospect-level LinkedIn post content is not available; employer posts come from `enrich-business-linkedin-posts`.
- Department is empty for many cross-functional senior roles (Chief X Officer, President, Founder); group them as "Unattributed".
