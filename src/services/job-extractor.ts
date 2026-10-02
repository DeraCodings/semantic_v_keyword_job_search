import { config } from "../config/env.js";
import { generateEmbedding } from "./embedder.js";
import { JobPosting, ScrapedPage } from "../types/index.js";
import { retryWithBackoff } from "../utils/rate-limiter.js";

const OPENROUTER_API_URL = "https://openrouter.ai/api/v1/chat/completions";

const SYSTEM_PROMPT = `
You are a precise technical data extraction engine.
Parse scraped job posting content into a clean JSON structure:
{
  "title": "Job Title (e.g. PostgreSQL Engineer)",
  "company": "Company Name",
  "location": "Job Location or Remote",
  "skills": ["Array of specific technical skills explicitly mentioned in the job posting. Only include skills present in the text above."]

  Do not include the description — it is stored separately.
}
`;

/**
 * Extracts structured JobPosting object from raw scraped Markdown
 */
export async function extractJobData(
  scrapedPage: ScrapedPage,
): Promise<JobPosting | null> {
  console.log(`🤖 LLM Extracting job data for: ${scrapedPage.url}`);

  const userPrompt = `
Scraped URL: ${scrapedPage.url}
Page Title: ${scrapedPage.title || "N/A"}
---
${scrapedPage.markdown}
---
`;

  let extracted: any = null;

  try {
    if (
      config.OPENROUTER_API_KEY &&
      config.OPENROUTER_API_KEY.startsWith("sk-or-v1-")
    ) {
      const rawResponseText = await retryWithBackoff(async () => {
        const response = await fetch(OPENROUTER_API_URL, {
          method: "POST",
          headers: {
            Authorization: `Bearer ${config.OPENROUTER_API_KEY}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            model: config.OPENROUTER_MODEL,
            messages: [
              { role: "system", content: SYSTEM_PROMPT },
              { role: "user", content: userPrompt },
            ],
            response_format: { type: "json_object" },
            temperature: 0.1,
            max_tokens: 8000,
          }),
        });

        if (!response.ok) {
          throw new Error(`OpenRouter API error (${response.status})`);
        }

        const data = await response.json();
        if (data.choices?.[0]?.finish_reason === "length") {
          console.warn(
            `⚠️ OpenRouter response truncated for ${scrapedPage.url}. Consider increasing max_tokens.`,
          );
        }
        return data.choices?.[0]?.message?.content;
      });

      if (rawResponseText) {
        console.log(`🔍 Raw LLM response length: ${rawResponseText.length}`);
        console.log(`🔍 First 200 chars: ${rawResponseText.slice(0, 200)}`);
        const cleanedJsonText = rawResponseText
          .replace(/^```json\s*/i, "")
          .replace(/^```\s*/i, "")
          .replace(/\s*```$/, "")
          .trim();
        extracted = JSON.parse(cleanedJsonText);
      }
    }
  } catch (error: any) {
    console.warn(
      `⚠️ OpenRouter extraction failed (${error.message}). Using intelligent heuristic fallback...`,
    );
  }

  if (!extracted) {
    console.warn(
      `⚠️ LLM extraction returned nothing for ${scrapedPage.url}, skipping`,
    );
    return null;
  }

  const fullTextForEmbedding = [
    extracted.title,
    extracted.company,
    extracted.description,
    ...(Array.isArray(extracted.skills) ? extracted.skills : []),
  ]
    .filter(Boolean)
    .join(" ")
    .trim();

  if (fullTextForEmbedding.length === 0) {
    console.warn(
      `⚠️ No valid text for embedding for ${scrapedPage.url}, skipping`,
    );
    return null;
  }

  const embedding = await generateEmbedding(fullTextForEmbedding);

  if (!embedding || embedding.length === 0) {
    console.error(`❌ Failed to generate embedding for ${scrapedPage.url}`);
    return null;
  }

  const hasRequiredFields =
    extracted.title &&
    extracted.title.trim().length > 0 &&
    (extracted.description || scrapedPage.markdown.length > 200);
  if (!hasRequiredFields) {
    console.warn(
      `⚠️ Extracted data missing required fields for ${scrapedPage.url}, skipping`,
    );
    return null;
  }

  const JOB_TITLE_PATTERN =
    /\b(engineer|developer|manager|architect|scientist|analyst|administrator|specialist|lead|director)\b/i;

  if (!JOB_TITLE_PATTERN.test(extracted.title || "")) {
    console.warn(
      `⚠️ Skipping ${scrapedPage.url}: title doesn't look like a job`,
    );
    return null;
  }

  const jobPosting: JobPosting = {
    title: extracted.title || "Technical Role",
    company: extracted.company || scrapedPage.companySlug,
    // description: extracted.description || "",
    description: scrapedPage.markdown.slice(0, 20000).replace(/\n+/g, " "), // store full scraped description, truncated to 20k chars
    location: extracted.location || "Remote",
    url: scrapedPage.url,
    skills: Array.isArray(extracted.skills) ? extracted.skills : ["Database"],
    embedding,
  };

  return jobPosting;
}

/**
 * Processes a batch of scraped pages and extracts structured JobPostings
 */
export async function extractJobBatch(
  pages: ScrapedPage[],
): Promise<JobPosting[]> {
  console.log(
    `🧠 Extracting structured job data from ${pages.length} pages...`,
  );
  const jobs: JobPosting[] = [];

  for (const page of pages) {
    try {
      const job = await extractJobData(page);
      if (job) {
        jobs.push(job);
      } else {
        console.warn(`⚠️ No job data extracted for ${page.url}, skipping.`);
      }
    } catch (error) {
      console.error(`❌ Error extracting job data for ${page.url}: `, error);
    }
  }

  console.log(
    `✅ Extraction complete. Successfully extracted ${jobs.length}/${pages.length} job postings.`,
  );
  return jobs;
}
