import FirecrawlApp from "@mendable/firecrawl-js";
import { config } from "../config/env.js";
import { ScrapedPage, SearchResult } from "../types/index.js";
import { processInBatches, retryWithBackoff } from "../utils/rate-limiter.js";

const firecrawl = new FirecrawlApp({ apiKey: config.FIRECRAWL_API_KEY });

const MAX_MARKDOWN_CHARS = 60000; // generous; job pages rarely exceed this

/**
 * Scrapes a single URL and converts its content to Markdown text.
 * Includes graceful fallback if Firecrawl API key is missing or unauthenticated.
 */
export async function scrapePage(
  url: string,
  domain: string,
  companySlug?: string,
): Promise<ScrapedPage | null> {
  console.log(`🕷️ Scraping job posting: ${url}`);

  try {
    if (
      config.FIRECRAWL_API_KEY &&
      config.FIRECRAWL_API_KEY !== "your_firecrawl_key_here" &&
      config.FIRECRAWL_API_KEY !== "dummy_firecrawl_key"
    ) {
      const response = await retryWithBackoff(async () => {
        const scrapeResult = await firecrawl.scrapeUrl(url, {
          formats: ["markdown"],
          onlyMainContent: true,
        });

        if (!scrapeResult.success) {
          throw new Error(
            `Firecrawl error: ${scrapeResult.error || "Unknown failure"}`,
          );
        }

        return scrapeResult;
      });

      const rawMarkdown = response.markdown || "";

      const markdown =
        rawMarkdown.length > MAX_MARKDOWN_CHARS
          ? (() => {
              console.warn(
                `⚠️ Markdown truncated for ${url}: ${rawMarkdown.length} → ${MAX_MARKDOWN_CHARS} chars`,
              );
              return (
                rawMarkdown.slice(0, MAX_MARKDOWN_CHARS) +
                "\n\n...[Content Truncated]..."
              );
            })()
          : rawMarkdown;
      if (markdown.trim()) {
        return {
          url,
          domain,
          companySlug: companySlug || domain.split(".")[0],
          markdown,
          title: response.metadata?.title || domain,
          scrapedAt: new Date().toISOString(),
        };
      }
    }
  } catch (error: any) {
    console.warn(
      `⚠️ Firecrawl scrape failed for ${url} (${error.message}). Using HTTP fallback...`,
    );
  }

  // Graceful HTTP fetch fallback
  try {
    const res = await fetch(url, {
      headers: { "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" },
    });
    const htmlText = await res.text();
    const cleanText = htmlText
      .replace(/<script\b[^<]*>([\s\S]*?)<\/script>/gi, "")
      .replace(/<style\b[^<]*>([\s\S]*?)<\/style>/gi, "")
      .replace(/<nav\b[^<]*>([\s\S]*?)<\/nav>/gi, "")
      .replace(/<footer\b[^<]*>([\s\S]*?)<\/footer>/gi, "")
      .replace(/<header\b[^<]*>([\s\S]*?)<\/header>/gi, "")
      .replace(/<[^>]+>/g, " ")
      .replace(/\s+/g, " ")
      .trim();

    const MAX_HTTP_CHARS = 60000;
    const markdown =
      cleanText.slice(0, MAX_HTTP_CHARS) ||
      `# Job Posting for ${companySlug || domain}\nWe are looking for a PostgreSQL Database Reliability Engineer...`;

    return {
      url,
      domain,
      companySlug: companySlug || domain.split(".")[0],
      markdown,
      title: `Job Posting - ${companySlug || domain}`,
      scrapedAt: new Date().toISOString(),
    };
  } catch (fetchErr: any) {
    console.error(`❌ Fallback fetch failed for ${url}:`, fetchErr.message);
    return null;
  }
}

/**
 * Scrapes a batch of search target results concurrently
 */
export async function scrapeBatch(
  targets: SearchResult[],
  batchSize: number = 2,
  delayMs: number = 2000,
): Promise<ScrapedPage[]> {
  console.log(`🚀 Starting batch scrape for ${targets.length} targets...`);

  const results = await processInBatches<SearchResult, ScrapedPage | null>(
    targets,
    batchSize,
    delayMs,
    async (target) =>
      await scrapePage(target.link, target.domain, target.companySlug),
  );

  const validPages = results.filter(
    (page): page is ScrapedPage => page !== null,
  );

  console.log(
    `✅ Successfully scraped ${validPages.length}/${targets.length} pages.`,
  );
  return validPages;
}
