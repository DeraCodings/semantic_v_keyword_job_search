/**
 * Search engine result returned from SerpApi Google search query
 */
export interface SearchResult {
  title: string;
  link: string;
  snippet: string;
  domain: string;
  companySlug: string;
  platform?: string;
  sourceQuery: string;
}

/**
 * Raw page markdown content scraped via Firecrawl API
 */
export interface ScrapedPage {
  url: string;
  domain: string;
  companySlug: string;
  markdown: string;
  title?: string;
  scrapedAt: string;
}

/**
 * Structured job posting representation ready for PostgreSQL ingestion
 */
export interface JobPosting {
  id?: number;
  title: string;
  company: string;
  description: string;
  location?: string;
  url: string;
  skills: string[];
  createdAt?: string;
  embedding?: number[] | null;
}

/**
 * Result format for keyword and vector search queries
 */
export interface SearchResultItem {
  id: number;
  title: string;
  company: string;
  description: string;
  location?: string;
  url: string;
  skills: string[];
  rank?: number;
  distance?: number;
}
