---
name: enrich-company
description: "Look up one company, or a pasted list of up to 50 names or domains, and add firmographics, tech stack, funding and acquisitions, workforce and hiring trends, ratings, company hierarchy, website changes, or LinkedIn posts. Use for 'enrich this company', 'what does acme.com use', 'how big is Stripe', 'funding history for Asana', 'add industry and headcount to this list of domains'. Not for finding new companies (use list-builder) or a full multi-section brief (use account-research)."
---

# Enrich Company

Resolve named companies to Vibe Prospecting records, then add the data the user asked for.

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

One or more company names or domains, typed or pasted (up to 50 per match call). A name plus a domain matches best. Optional: which kinds of data the user wants.

## Workflow

1. **Match.** Call `match-business` with each company's `name` and/or `domain`. The result is complete, so read it directly.
2. **Check the match.** A well-known brand that resolves to 1-50 employees in a "Corporate Managing Offices" category probably landed on a registered-agent shell. Retry with the alternate domain or the plain company name. The match has no confidence score, so when the candidates look ambiguous, ask the user instead of guessing. Report unmatched rows and do not substitute other companies.
3. **Choose enrichments** from what the user asked for. With no preference, use firmographics plus technographics.

   | Need | Enrichment |
   |---|---|
   | Name, description, size, revenue, location, industry | `enrich-business-firmographics` |
   | Tech stack | `enrich-business-technographics` |
   | Web infrastructure | `enrich-business-webstack` |
   | Rounds, investors, IPO, acquisitions | `enrich-business-funding-and-acquisitions` |
   | Headcount and department trends | `enrich-business-workforce-trends` |
   | Employee-satisfaction ratings | `enrich-business-company-ratings` |
   | Parent, subsidiaries, org tree | `enrich-business-company-hierarchies` |
   | Public-company financials | `enrich-business-financial-metrics` (needs `parameters.date`) |
   | Keywords on their website | `enrich-business-website-keywords` (needs `parameters.keywords`) |
   | Site content changes | `enrich-business-website-changes` |
   | Recent company posts | `enrich-business-linkedin-posts` |
   | Risks, competitors, strategy (from filings) | `enrich-business-challenges`, `enrich-business-competitive-landscape`, `enrich-business-strategic-insights` |

   Use the schema's exact enum names. Run at most 3 per `enrich-business` call, each on the latest `table_name`.
4. **Show:** call `show-sample` on the final table. It reveals up to 5 rows, so for a longer list, say so and offer the export for the rest.

## Reply

One short card per company (up to 5): name, domain, industry, headcount bucket, revenue bucket, HQ, public or private, then the enrichments requested. Leave out empty fields and name any enrichment that came back empty, so the user can tell missing data from data that was never requested.

## Limitations

- Risks, competitors and strategy come from public filings: empty for private companies and 12-18 months old for public ones. Use funding, workforce trends, events and posts for current signals.
- Headcount and revenue are buckets. Quote the bucket, not an exact number.
- Matching returns an ID or nothing, with no confidence score.
- Only 3 enrichment types per call, so wide requests take several calls.
