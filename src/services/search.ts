import { getJson } from "serpapi";
import { config } from "../config/env.js";
import { DATABASE_SEARCH_PRESETS } from "../config/search-presets.js";
import { SearchResult } from "../types/index.js";
import { retryWithBackoff } from "../utils/rate-limiter.js";

export { DATABASE_SEARCH_PRESETS };

/**
 * Extracts clean domain name from a URL string
 */
export function extractDomain(url: string): string {
  try {
    const parsed = new URL(url);
    return parsed.hostname.replace(/^www\./, "").toLowerCase();
  } catch {
    return "";
  }
}

export interface ParsedTarget {
  domain: string;
  companySlug: string;
  platform: string;
}

/**
 * Intelligent URL parser that extracts company slug from ATS job board URLs
 */
export function parseUrlTarget(url: string): ParsedTarget {
  const domain = extractDomain(url);
  let companySlug = "";
  let platform = "direct";

  try {
    const parsed = new URL(url);
    const pathSegments = parsed.pathname.split("/").filter(Boolean);

    if (domain.includes("greenhouse.io")) {
      platform = "greenhouse";
      companySlug = pathSegments[0] || "";
    } else if (domain.includes("lever.co")) {
      platform = "lever";
      companySlug = pathSegments[0] || "";
    } else if (domain.includes("ashbyhq.com")) {
      platform = "ashby";
      companySlug = pathSegments[0] || "";
    } else if (domain.includes("workable.com")) {
      platform = "workable";
      // Prefer the slug after "/view/{id}/", fall back to first segment
      const slug = pathSegments[2] || pathSegments[0] || "";
      const match = slug.match(/-at-(.+)$/);
      companySlug = match ? match[1] : slug;
    } else {
      platform = "direct";
      const parts = domain.split(".");
      companySlug = parts.length > 2 ? parts[parts.length - 2] : parts[0];
    }
  } catch {
    companySlug = domain.split(".")[0];
  }

  companySlug = companySlug.toLowerCase().replace(/[^a-z0-9_-]/g, "");
  return { domain, companySlug, platform };
}

/**
 * Executes a Google search via SerpApi with rate-limit retries
 */
export async function searchGoogle(
  query: string,
  numResults: number = 10,
): Promise<SearchResult[]> {
  console.log(`🔎 Executing SerpApi search: "${query}"`);

  if (
    !config.SERPAPI_API_KEY ||
    config.SERPAPI_API_KEY === "dummy_serpapi_key"
  ) {
    throw new Error("SERPAPI_API_KEY is required. Set it in .env");
  }

  const response = await retryWithBackoff(async () => {
    return await getJson({
      engine: "google",
      q: query,
      num: numResults,
      api_key: config.SERPAPI_API_KEY,
    });
  });

  const rawResults = response.organic_results || [];

  return rawResults.map((item: any) => {
    const link = item.link || "";
    const { domain, companySlug, platform } = parseUrlTarget(link);

    return {
      title: item.title || "",
      link,
      snippet: item.snippet || "",
      domain,
      companySlug,
      platform,
      sourceQuery: query,
    };
  });
}

/**
 * Discovers target job posting URLs across multiple query templates
 */
export async function discoverTargets(
  queries: string[],
  resultsPerQuery: number = 5,
): Promise<SearchResult[]> {
  const allResults: SearchResult[] = [];
  const seenUrls = new Set<string>();

  const BLOCKED_DOMAINS = [
    "reddit.com",
    "linkedin.com",
    "tealhq.com",
    "twitter.com",
    "x.com",
    "medium.com",
    "youtube.com",
    "facebook.com",
    "instagram.com",
    "glassdoor.com",
    "quora.com",
    "pinterest.com",
    "tiktok.com",
  ];

  function isJobPostingUrl(url: string): boolean {
    try {
      const host = new URL(url).hostname.replace(/^www\./, "").toLowerCase();
      return !BLOCKED_DOMAINS.some((d) => host === d || host.endsWith(`.${d}`));
    } catch {
      return false;
    }
  }

  for (const query of queries) {
    try {
      const results = await searchGoogle(query, resultsPerQuery);

      for (const result of results) {
        if (!isJobPostingUrl(result.link)) continue;
        if (seenUrls.has(result.link)) continue;
        seenUrls.add(result.link);
        allResults.push(result);
      }
    } catch (err: any) {
      console.error(
        `⚠️ Skipping query "${query}" due to error: ${err.message}`,
      );
    }
  }

  console.log(`🎯 Discovered ${allResults.length} unique job posting targets.`);
  return allResults;
}
