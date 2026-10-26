---
name: enrich-contact
description: "Look up one person or a small pasted list of people and return their professional profile and contact details: work email, phone, LinkedIn, title, seniority, department, work history, and recent job changes. Identify people by email, LinkedIn URL, phone number, or full name plus company. Use for 'find the email for Jane Smith at Acme', 'enrich this contact', 'who is this person', 'background on these attendees'. Not for finding new people by role (use list-builder or account-contacts) or for drafting outreach."
---

# Enrich Contact

Resolve people to Vibe Prospecting records, then add the profile and contact data the user asked for.

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

For each person, one of: an email, a LinkedIn URL, a phone number, or a full name with a company name or domain. A name without a company cannot be matched. Up to 40 people per `match-prospects` call. Optional: whether the user wants contact details, a profile, or career changes.

## Workflow

1. **Pick the strongest identifier** for each person: email, then LinkedIn URL, then phone, then name plus company. Do not fan out several strategies for one person. If the user gave a role instead of a name ("the CFO at Asana"), do not match on the title; use `match-business` to get the company, then `fetch-entities` for prospects filtered by title and seniority, and let the user choose.
2. **Match.** Call `match-prospects`. For a name plus company, add the company's `business_id` from `match-business` when you have it. Results are complete: a person is either matched or null. A typo in an email is a miss; do not retry it as a name search, since that could return a different person.
3. **Report misses.** Say which people did not match and why a retry might help: an email, LinkedIn URL or company domain improves the odds. Enrich only the matched people. Do not replace an unmatched person with someone similar.
4. **Enrich** the matched table with `enrich-prospects`:
   - `enrich-prospects-profiles` for title, location, work history and education.
   - `enrich-prospects-contacts` for email and phone. Set `contact_types` to `["email"]` unless the user needs phone numbers too; leaving it empty requests both.
   Company context, if asked for, comes from `enrich-business` with `enrich-business-firmographics` on the employer.
5. **Career changes,** if asked: `fetch-prospects-events` with `prospect_changed_role` or `prospect_changed_company` and a `timestamp_from`. These are the only people-level event types.
6. **Show:** `show-sample` on the final table. It reveals up to 5 rows. For more people, summarize the first 5 and offer the export.

## Reply

A card per person (up to 5): name, title, company, seniority, department ("Unattributed" if empty), professional email, phone, LinkedIn. When the user asked for background, add a 3-5 sentence synopsis written only from the returned data: current role, one or two earlier roles, tenure, and any recent change. Say "not available" for thin profiles instead of guessing.

## Limitations

- High-profile executives often have suppressed contact data. Suggest LinkedIn instead of cold email.
- No per-contact accuracy score and no "last updated" date. Treat a professional email plus a phone as the practical quality signal.
- Seniority and department are coarse; department is empty for many Chief X Officer, President and Founder roles.
- Per-person LinkedIn post content is not available. Employer posts come from `enrich-business-linkedin-posts`.
- Do not use contact data for anything beyond the lookup the user asked for.
