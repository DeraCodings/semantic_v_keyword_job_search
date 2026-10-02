import cors from "cors";
import express, { type Request, type Response } from "express";
import {
  getJobCount,
  insertJob,
  isJobKnown,
  searchJobsKeyword,
  searchJobsVector,
} from "./db/repository.js";
import { generateEmbedding } from "./services/embedder.js";
import { extractJobBatch } from "./services/job-extractor.js";
import { scrapeBatch, scrapePage } from "./services/scraper.js";
import {
  DATABASE_SEARCH_PRESETS,
  discoverTargets,
  parseUrlTarget,
} from "./services/search.js";
import { ScrapedPage, SearchResult } from "./types/index.js";
import { query } from "./db/index.js";

const app = express();
const PORT = process.env.PORT ? parseInt(process.env.PORT, 10) : 3000;

app.use(cors());
app.use(express.json());

// Check system health, database status, and total stored jobs count
app.get("/api/health", async (_, res) => {
  try {
    const jobCount = await getJobCount();
    res.json({
      status: "online",
      service: "Percona Job Search API",
      database: "PostgreSQL 18 + pgvector",
      totalStoredJobs: jobCount,
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Discover, scrape, extract, and ingest new job postings into PostgreSQL
app.post("/api/jobs/ingest", async (req: Request, res) => {
  try {
    const { preset, query, urls, limit = 5 } = req.body;
    const searchTargets: SearchResult[] = [];
    const directPages: ScrapedPage[] = [];

    console.log("Ingest params:", { preset, query, limit, urls });

    // Step 1: Discover targets based on preset, query, or direct URLs
    if (preset) {
      const presetKey =
        preset.toUpperCase() as keyof typeof DATABASE_SEARCH_PRESETS;
      const queries = DATABASE_SEARCH_PRESETS[presetKey];
      if (!queries) {
        return res.status(400).json({
          error: `Invalid preset '${preset}'. Valid options: ${Object.keys(DATABASE_SEARCH_PRESETS).join(", ")}`,
        });
      }
      const discovered = await discoverTargets([...queries], Number(limit));
      searchTargets.push(...discovered.slice(0, Number(limit)));
    } else if (query) {
      const discovered = await discoverTargets([query], Number(limit));
      searchTargets.push(...discovered);
    } else if (urls && Array.isArray(urls)) {
      for (const url of urls) {
        const { domain, companySlug } = parseUrlTarget(url);
        const scraped = await scrapePage(url, domain, companySlug);
        if (scraped) directPages.push(scraped);
      }
    } else {
      const queries = DATABASE_SEARCH_PRESETS.POSTGRESQL_JOBS;
      const discovered = await discoverTargets([...queries], Number(limit));
      searchTargets.push(...discovered);
    }

    // Step 2: Skip URLs already existing in PostgreSQL
    const newTargets: SearchResult[] = [];
    for (const target of searchTargets) {
      const exists = await isJobKnown(target.link);
      if (!exists) newTargets.push(target);
    }

    // Step 3: Scrape web pages via Firecrawl or HTTP fallback
    const scrapedPages: ScrapedPage[] = [...directPages];
    if (newTargets.length > 0) {
      const freshlyScraped = await scrapeBatch(newTargets, 2, 2000);
      scrapedPages.push(...freshlyScraped);
    }

    // Step 4: Extract structured fields and generate vector embeddings
    const jobPostings = await extractJobBatch(scrapedPages);

    // Step 5: Save job records into PostgreSQL database
    let insertedCount = 0;
    for (const job of jobPostings) {
      const inserted = await insertJob(job);
      if (inserted) insertedCount++;
    }

    const totalJobs = await getJobCount();
    res.json({
      success: true,
      scrapedPagesCount: scrapedPages.length,
      insertedCount,
      totalStoredJobs: totalJobs,
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Perform full-text keyword search using PostgreSQL tsvector
app.get("/api/search/keyword", async (req: Request, res: Response) => {
  try {
    const q = req.query.q as string;
    const limit = Number(req.query.limit || 10);

    if (!q) {
      return res.status(400).json({ error: "Query parameter 'q' is required" });
    }

    const startTime = performance.now();
    const results = await searchJobsKeyword(q, limit);
    const executionTimeMs = parseFloat(
      (performance.now() - startTime).toFixed(2),
    );

    res.json({
      engine: "PostgreSQL tsvector",
      query: q,
      executionTimeMs,
      count: results.length,
      results,
      message:
        results.length < 1
          ? `No job results for ${q} found`
          : `Found ${results.length} jobs for ${q}`,
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Perform semantic vector search using pgvector and jina embeddings
app.get("/api/search/vector", async (req: Request, res: Response) => {
  try {
    const q = req.query.q as string;
    const limit = Number(req.query.limit || 10);

    if (!q) {
      return res.status(400).json({ error: "Query parameter 'q' is required" });
    }

    const startTime = performance.now();
    const queryEmbedding = await generateEmbedding(q);
    if (!queryEmbedding || queryEmbedding.length === 0) {
      return res
        .status(500)
        .json({ error: "Failed to generate query embedding" });
    }
    const results = await searchJobsVector(queryEmbedding, limit);
    const executionTimeMs = parseFloat(
      (performance.now() - startTime).toFixed(2),
    );

    res.json({
      engine: "PostgreSQL pgvector (Jina Embedding API)",
      query: q,
      executionTimeMs,
      count: results.length,
      results,
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Compare keyword search vs semantic vector search side-by-side
app.get("/api/benchmark", async (req: Request, res: Response) => {
  try {
    const q = req.query.q as string;
    const limit = Number(req.query.limit || 5);

    if (!q) {
      return res.status(400).json({ error: "Query parameter 'q' is required" });
    }

    // 1. Keyword Search
    const kwStart = performance.now();
    const kwResults = await searchJobsKeyword(q, limit);
    const kwTimeMs = parseFloat((performance.now() - kwStart).toFixed(2));

    // 2. Vector Search
    const vecStart = performance.now();
    const queryEmbedding = await generateEmbedding(q);
    if (!queryEmbedding || queryEmbedding.length === 0) {
      console.error("Failed to generate query embedding for benchmark");
      return res
        .status(500)
        .json({ error: "Failed to generate query embedding" });
    }
    const vecResults = await searchJobsVector(queryEmbedding, limit);
    const vecTimeMs = parseFloat((performance.now() - vecStart).toFixed(2));

    res.json({
      benchmark: "Keyword Search (tsvector) vs Semantic Search (pgvector)",
      query: q,
      keywordSearch: {
        engine: "tsvector",
        executionTimeMs: kwTimeMs,
        count: kwResults.length,
        results: kwResults,
      },
      vectorSearch: {
        engine: "pgvector (Jina Embedding API)",
        executionTimeMs: vecTimeMs,
        count: vecResults.length,
        results: vecResults,
      },
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});


// Debug endpoint to compute cosine distances for sample queries
app.get("/api/debug/distances", async (_, res: Response) => {
  const queries = [
    "postgres",
    "database",
    "developer",
    "backend engineer",
    "writer",
    "ui_developer",
    "nurse",
    "chef",
  ];

  const output: Record<
    string,
    { id: string; title: string; distance: number }[]
  > = {};

  for (const q of queries) {
    const embedding = await generateEmbedding(q);
    const result = await query(
      `SELECT id, title, (embedding <=> $1::vector) AS distance
       FROM jobs
       WHERE embedding IS NOT NULL
       ORDER BY distance ASC`,
      [JSON.stringify(embedding)],
    );
    output[q] = result.rows.map((r) => ({
      id: r.id,
      title: r.title,
      distance: parseFloat(r.distance),
    }));
  }

  res.json(output);
});

app.listen(PORT, () => {
  console.log(
    `\n🚀 Percona Job Search Express API running on http://localhost:${PORT}\n`,
  );
});
