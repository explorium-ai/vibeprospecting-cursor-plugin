---
name: market-sizing
description: "Size a market: count how many companies match an ideal customer profile, refine the filters with the user until the number makes sense, and return the final filter set. Use for 'how many companies match', 'size the market for X', 'TAM for fintech in the UK', 'is my ICP too broad', 'territory sizing', or a rough SAM estimate. Counts and breakdowns only, with no list of companies unless asked. Not for building the list itself (use list-builder)."
---

# Market Sizing

Refine a company-level ICP and report how many companies match, using statistics instead of pulling rows.

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

- **ICP** in plain language, or "my ICP" with details to ask for.
- **Use case (optional):** territory design, investor sizing, or ICP sharpening (default).
- **SAM inputs (optional):** an addressable fraction (0-1) and average revenue per account in USD.

## Workflow

1. **Parse the ICP** into filter dimensions and note which the user stated. Persona details ("CTOs", "VP Sales") are recorded but do not change a company count.
2. **Disambiguate regions first.** "EU" can mean EU member states or all of Europe; "Americas" can mean North America or the US and Canada. Ask one question, then count.
3. **Resolve free-text values** with `autocomplete`, then sort each into one of three outcomes before counting:
   - *Clean match:* an unambiguous canonical value. Use it.
   - *Parent or brittle match:* only a parent or sibling exists (for example "fintech" maps only to "Financial Services"). Stop and show the nearest entries, then ask whether to approximate with the parent, use a technology or intent proxy, or drop it. Do not substitute silently.
   - *No match* after 2-3 phrasings (bare term, full product name, vendor plus suffix): say there is no matching value and offer the same options.
   For flagship vendors, try the product-qualified name first ("Snowflake Data Cloud", "Stripe Payments").
   One industry taxonomy per query: try `linkedin_category` first and use `naics_category` only when LinkedIn has no clean match.
4. **Count** with `fetch-entities-statistics` (`entity_type: businesses`) on the resolved filters. For a country-scoped count, add the per-location breakdown for the requested countries instead of the headline total, because the headline may include other countries. State the numbers you used.
5. **Compare filter impact** whenever a tech-stack or intent filter is applied. Count with and without that filter and show both. A small filtered share can reflect a selective criterion or incomplete coverage; the ratio alone cannot distinguish them. Keep the filtered count as the count matching the requested ICP. Describe the unfiltered count as a broader comparison pool, and do not drop a requested criterion without the user agreeing.
6. **Classify the working number:** over 50,000 is too broad; 5,000-50,000 healthy, so suggest tiers; 1,000-5,000 is a sweet spot; 250-1,000 is niche, so check capacity; under 250 is too narrow, so suggest widening.
7. **Sample accounts only when needed.** The default is counts only. Run `fetch-entities` (businesses) and `show-sample` if the user asked for names, if a filter produces questionable matches, or if you accepted a parent approximation and want to see whether it captured what the user meant. The sample shows 5 rows and is directional, not ranked; do not compute percentages from it. If the rows reveal irrelevant matches, describe the examples, refine the filters with the user, and re-count. Do not extrapolate a noise rate or adjusted market count from an unsorted five-row sample.
8. **SAM (only if both inputs were given):** companies × fraction, then × revenue per account. Label it a hypothesis, not a forecast.
9. **Offer refinements,** each naming a dimension and the likely effect on the count, and re-count after any change. Finish by offering `list-builder` with the final filter set.

## Reply

- **Headline:** "about [count] companies" rounded to two significant figures, and the band. Show raw, filtered and unfiltered numbers when the filter-impact comparison was run.
- **Filters applied:** dimension, value, and source (stated by the user, assumed, or approximated). Persona criteria are marked "not applied to the company count".
- **Sample accounts** (only if run): why it was run, and the noise you found.
- **Refinements** or the final filter set.
- **SAM** if requested.

## Limitations

- Size and revenue are buckets, and revenue buckets look like an estimate derived from headcount, so one bucket often dominates. Do not slice revenue after fixing size.
- Samples are unsorted and directional.
- No metro-area filter; geography is country, region or US city.
- Persona criteria are never applied to the company count.
- No Inc 5000 or Fortune ranking filter; public or private is the only company-type flag.
- Flagship vendor names sometimes autocomplete poorly; surface that instead of substituting.
