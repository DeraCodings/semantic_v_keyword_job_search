Ingest params: {
  preset: 'data_engineer',
  query: undefined,
  limit: 10,
  urls: undefined
}
🔎 Executing SerpApi search: "(site:boards.greenhouse.io OR site:jobs.lever.co OR site:jobs.ashbyhq.com OR site:jobs.workable.com OR site:jobs.smartrecruiters.com) ("Data Engineer" OR "Analytics Infrastructure" OR "ETL Pipeline") -site:reddit.com -site:linkedin.com -site:tealhq.com"
🎯 Discovered 10 unique job posting targets.
🚀 Starting batch scrape for 10 targets...
⏳ Processing batch 1 of 5...
🕷️ Scraping job posting: https://jobs.ashbyhq.com/baseten/c2ba6c50-d282-4478-98e9-668f94facde8
🕷️ Scraping job posting: https://jobs.ashbyhq.com/runpod/a63e8c2f-a319-4655-8179-b024a45db782
⏳ Processing batch 2 of 5...
🕷️ Scraping job posting: https://jobs.ashbyhq.com/talkiatry/c20f10a0-b493-4109-866c-a6c755677735
🕷️ Scraping job posting: https://jobs.ashbyhq.com/tem/9d3b99f8-8b01-4bd9-99e0-a037aadc0b2e
⏳ Processing batch 3 of 5...
🕷️ Scraping job posting: https://jobs.ashbyhq.com/benchling/c1ad7288-ad78-4a0f-8f19-1fcc3f6cf85b
🕷️ Scraping job posting: https://jobs.ashbyhq.com/superhuman%20platform%20inc/18537659-6a5f-447f-8f77-77f16ee1e7f0
⏳ Processing batch 4 of 5...
🕷️ Scraping job posting: https://jobs.ashbyhq.com/serval/60e9f06a-e473-438d-b8e4-916f5dadc2f5
🕷️ Scraping job posting: https://jobs.ashbyhq.com/ready/d7ada023-ac2b-42bb-8196-0836f97d6440
⏳ Processing batch 5 of 5...
🕷️ Scraping job posting: https://jobs.ashbyhq.com/e-source/c51ce732-744f-418e-9ba9-f553b6256090
🕷️ Scraping job posting: https://jobs.ashbyhq.com/revenuebase-inc/1a9f2caa-d293-4297-a90d-8162e0f7972e
✅ Successfully scraped 10/10 pages.
🧠 Extracting structured job data from 10 pages...
🤖 LLM Extracting job data for: https://jobs.ashbyhq.com/baseten/c2ba6c50-d282-4478-98e9-668f94facde8
⚠️ LLM extraction returned nothing for https://jobs.ashbyhq.com/baseten/c2ba6c50-d282-4478-98e9-668f94facde8, skipping
⚠️ No job data extracted for https://jobs.ashbyhq.com/baseten/c2ba6c50-d282-4478-98e9-668f94facde8, skipping.
🤖 LLM Extracting job data for: https://jobs.ashbyhq.com/runpod/a63e8c2f-a319-4655-8179-b024a45db782
⚠️ LLM extraction returned nothing for https://jobs.ashbyhq.com/runpod/a63e8c2f-a319-4655-8179-b024a45db782, skipping
⚠️ No job data extracted for https://jobs.ashbyhq.com/runpod/a63e8c2f-a319-4655-8179-b024a45db782, skipping.
🤖 LLM Extracting job data for: https://jobs.ashbyhq.com/talkiatry/c20f10a0-b493-4109-866c-a6c755677735
🔍 Raw LLM response length: 464
🔍 First 200 chars: {
  "title": "Data Engineer",
  "company": "Talkiatry",
  "location": "Remote",
  "skills": [
    "Python",
    "AWS",
    "Lambda",
    "ECS",
    "dbt",
    "Snowflake",
    "SQL",
    "window funct
🧠 Generated Jina vector embedding (1024 dimensions)
First 15 embedding values: -0.02186269 -0.03273157 -0.04472482 -0.03198199 0.08345301 0.00446624 -0.04672369 -0.05621835 0.03672932 0.04947215 -0.00899494 0.00071444 -0.01068149 -0.03273157 -0.06121553
🤖 LLM Extracting job data for: https://jobs.ashbyhq.com/tem/9d3b99f8-8b01-4bd9-99e0-a037aadc0b2e
🔍 Raw LLM response length: 470
🔍 First 200 chars: {
  "title": "Senior Data Engineer",
  "company": "tem",
  "location": "United Kingdom (Remote)",
  "skills": [
    "Python",
    "AWS",
    "GCP",
    "Terraform",
    "ETL/ELT pipelines",
    "Batch
🧠 Generated Jina vector embedding (1024 dimensions)
First 15 embedding values: -0.06169816 -0.03272251 -0.04471244 -0.05295551 0.04995803 0.01442538 -0.03996642 -0.04246432 0.02310559 0.04246432 -0.03322209 0.00611986 -0.03422125 -0.03147356 -0.06944166
🤖 LLM Extracting job data for: https://jobs.ashbyhq.com/benchling/c1ad7288-ad78-4a0f-8f19-1fcc3f6cf85b
🔍 Raw LLM response length: 722
🔍 First 200 chars: {
  "title": "Data Engineer",
  "company": "Benchling",
  "location": "San Francisco, CA (Hybrid)",
  "skills": [
    "SQL",
    "Python",
    "dbt",
    "Snowflake",
    "AWS",
    "Airflow",
    "Sa
🧠 Generated Jina vector embedding (1024 dimensions)
First 15 embedding values: -0.04220809 -0.04393591 -0.04566372 -0.03973978 0.05701794 0.01653767 -0.04887252 -0.03949295 0.04541689 0.06960632 -0.0020055 0.00064022 -0.02332552 -0.03097728 -0.04763837
🤖 LLM Extracting job data for: https://jobs.ashbyhq.com/superhuman%20platform%20inc/18537659-6a5f-447f-8f77-77f16ee1e7f0
🔍 Raw LLM response length: 763
🔍 First 200 chars: {
  "title": "Data Engineer, Foundations",
  "company": "Superhuman",
  "location": "San Francisco or Seattle hubs (Hybrid)",
  "skills": [
    "SQL",
    "Python",
    "Spark",
    "Databricks",

🧠 Generated Jina vector embedding (1024 dimensions)
First 15 embedding values: -0.04559456 -0.02663812 -0.04162981 -0.06194913 0.03444371 0.0282488 -0.05079829 -0.04460337 0.05178947 0.06987862 -0.01313321 -0.01530143 -0.02552304 -0.03159406 -0.04311659
🤖 LLM Extracting job data for: https://jobs.ashbyhq.com/serval/60e9f06a-e473-438d-b8e4-916f5dadc2f5
🔍 Raw LLM response length: 639
🔍 First 200 chars: {
  "title": "Data Engineer",
  "company": "Serval",
  "location": "San Francisco",
  "skills": [
    "SQL",
    "PostgreSQL",
    "Python",
    "Data Warehousing",
    "Data Lakehousing",
    "Data P
🧠 Generated Jina vector embedding (1024 dimensions)
First 15 embedding values: -0.06697492 -0.02775934 -0.03811402 -0.05507806 0.04846869 0.00076077 -0.06212805 -0.03150465 0.03524996 0.09209051 -0.00881249 -0.02015857 -0.01327381 -0.026107 -0.04119839
🤖 LLM Extracting job data for: https://jobs.ashbyhq.com/ready/d7ada023-ac2b-42bb-8196-0836f97d6440
⚠️ LLM extraction returned nothing for https://jobs.ashbyhq.com/ready/d7ada023-ac2b-42bb-8196-0836f97d6440, skipping
⚠️ No job data extracted for https://jobs.ashbyhq.com/ready/d7ada023-ac2b-42bb-8196-0836f97d6440, skipping.
🤖 LLM Extracting job data for: https://jobs.ashbyhq.com/e-source/c51ce732-744f-418e-9ba9-f553b6256090
⚠️ LLM extraction returned nothing for https://jobs.ashbyhq.com/e-source/c51ce732-744f-418e-9ba9-f553b6256090, skipping
⚠️ No job data extracted for https://jobs.ashbyhq.com/e-source/c51ce732-744f-418e-9ba9-f553b6256090, skipping.
🤖 LLM Extracting job data for: https://jobs.ashbyhq.com/revenuebase-inc/1a9f2caa-d293-4297-a90d-8162e0f7972e
⚠️ LLM extraction returned nothing for https://jobs.ashbyhq.com/revenuebase-inc/1a9f2caa-d293-4297-a90d-8162e0f7972e, skipping
⚠️ No job data extracted for https://jobs.ashbyhq.com/revenuebase-inc/1a9f2caa-d293-4297-a90d-8162e0f7972e, skipping.
✅ Extraction complete. Successfully extracted 5/10 job postings