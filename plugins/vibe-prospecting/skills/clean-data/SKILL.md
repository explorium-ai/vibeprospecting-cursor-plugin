---
name: clean-data
description: "Tidy a pasted list of companies or contacts before matching or enrichment: normalize company names, domains, countries and emails, flag invalid rows with a reason, match each row to Vibe Prospecting records, and remove duplicates that resolve to the same company or person. Use for 'clean this list', 'match these companies to domains', 'dedupe these contacts', 'which of these emails are valid', 'prep this list for enrichment'. Works on lists pasted in chat, up to roughly 100 rows. Not for building a new list (use list-builder)."
---

# Clean Data

Standardize and check a pasted list, then match it so duplicates collapse onto real company or person records. Nothing is deleted: every row stays, with a status and reason.

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

A list of companies or contacts pasted in chat, or the text of an attached file. Roughly 100 rows is the practical limit in one conversation; for more, work in batches. Note which column is the company name, domain, email, LinkedIn URL, phone or country; ask only if it is unclear. For a very large file, suggest the user clean it in a spreadsheet first.

## Workflow

1. **Profile the input.** Report row count, fill rate for each field, and obvious problems: placeholder text ("N/A", "none", "-"), pasted addresses in the name field, many spellings of one country, free-email providers, and role addresses.
2. **Standardize,** keeping the raw value beside the normalized one:
   - *Company name:* trim, collapse spaces, remove stray punctuation, and drop a trailing legal suffix (Inc, LLC, Ltd, GmbH, S.A.) for matching only.
   - *Domain:* strip the protocol and `www`, keep the registrable domain, lowercase. Flag free-email domains separately.
   - *Country:* convert to ISO two-letter codes (`United States` → `US`, `UK` → `GB`, `Deutschland` → `DE`).
   - *Email:* trim and lowercase.
   - *LinkedIn:* keep the full profile URL.
3. **Validate** each field and tag the row; never delete one:
   - *Email:* syntax, role addresses (`info@`, `sales@`, `noreply@`, `support@`), well-known free or disposable providers. You cannot check deliverability or mail servers, so say that valid means well-formed.
   - *Domain:* looks like a real domain, no IP address or spaces.
   - *Country:* resolves to a code.
   Give each problem a short reason code (`role_address`, `free_provider`, `invalid_syntax`, `placeholder`).
4. **Match the valid rows.**
   - Companies with a name and/or domain: `match-business`, up to 50 per call.
   - People: `match-prospects`, up to 40 per call, by email, LinkedIn URL or phone number, or full name plus company name (add the company's `business_id` when you have it). Skip rows tagged as role addresses or disposable domains so you do not spend matching on them.
   Match results are complete, so read them directly. Check a resolved company for the shell-entity pattern (a big brand with 1-50 employees under "Corporate Managing Offices") and retry with the other domain. An email miss stays a miss; never retry it as a name search.
5. **Deduplicate on the IDs.** Rows that resolve to the same business ID or prospect ID are duplicates; keep the first, mark the others with the ID of the survivor. Different IDs are different entities even if the names look alike, and subsidiaries or brands under one parent (for example a parent and its product domains) are separate companies; `enrich-business-company-hierarchies` shows the tree.
6. **Report** and offer next steps.

## Reply

- **Profile:** a short before-and-after summary of fill rates and the issues found.
- **Standardization:** three to five example changes (`"  ACME, Inc. "` → `acme`, `"WWW.Acme.COM"` → `acme.com`).
- **Validation:** counts of valid and invalid rows and a frequency list of reason codes.
- **Result table:** the input row, normalized value, status (matched, unmatched, invalid, duplicate of row N), reason, and the matched name and domain. Show the first rows in chat and offer the rest in batches; do not export unless asked.
- **Next steps:** enrich the matched rows with `enrich-company` or `enrich-contact`, or score them with `score-leads`. If the match rate is low, suggest adding LinkedIn URLs, company domains or work emails.

## Limitations

- Validation checks format only: no deliverability or mail-server check, and no phone verification.
- Person-name parsing is simple; non-Western name orders and compound surnames may need the user's confirmation.
- Free-email addresses cannot be tied to a company by themselves; pair them with a name and company for a prospect match.
- Matching returns an ID or nothing, with no confidence score.
- Works in chat, so very large files need to be split.
