import { Command } from "commander";
import { closePool } from "./db/index.js";
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

const program = new Command();

program
  .name("percona-semantic-job-search")
  .description(
    "Percona Community Article Demo: PostgreSQL Keyword Search (tsvector) vs. Semantic Search (pgvector)"
  )
  .version("1.0.0");

/**
 * Ingest Command: Discovers job postings, scrapes raw Markdown via Firecrawl,
 * extracts structured job metadata via OpenRouter LLM, and inserts records into PostgreSQL.
 */
program
  .command("ingest")
  .description("Discover, scrape, extract, and ingest job postings into PostgreSQL")
  .option(
    "-p, --preset <preset>",
    "Search preset: POSTGRESQL_JOBS, DATABASE_ENGINEER, DATA_ENGINEER, BACKEND_DEVELOPER, INFRASTRUCTURE_ENGINEER"
  )
  .option("-q, --query <query>", "Custom Google Dork search query string")
  .option("-u, --urls <urls...>", "Direct list of target job URLs to scrape")
  .option("-l, --limit <number>", "Max search results per query", "5")
  .action(async (options) => {
    console.log("\n🚀 Starting Percona Job Data Ingestion Pipeline...\n");

    try {
      const limit = parseInt(options.limit || "5", 10);
      const searchTargets: SearchResult[] = [];
      const directPages: ScrapedPage[] = [];

      // 1. Target Discovery
      if (options.preset) {
        const presetKey =
          options.preset.toUpperCase() as keyof typeof DATABASE_SEARCH_PRESETS;
        const queries = DATABASE_SEARCH_PRESETS[presetKey];

        if (!queries) {
          console.error(
            `❌ Invalid preset "${options.preset}". Valid options:\n` +
              Object.keys(DATABASE_SEARCH_PRESETS)
                .map((k) => `   • ${k}`)
                .join("\n")
          );
          process.exit(1);
        }

        console.log(`🔍 Running search preset strategy: ${presetKey}`);
        const discovered = await discoverTargets([...queries], limit);
        searchTargets.push(...discovered);
      } else if (options.query) {
        console.log(`🔍 Running custom search query: "${options.query}"`);
        const discovered = await discoverTargets([options.query], limit);
        searchTargets.push(...discovered);
      } else if (options.urls && options.urls.length > 0) {
        console.log(`🌐 Processing ${options.urls.length} direct target URLs...`);
        for (const url of options.urls) {
          const { domain, companySlug } = parseUrlTarget(url);
          const scraped = await scrapePage(url, domain, companySlug);
          if (scraped) directPages.push(scraped);
        }
      } else {
        console.log("ℹ️ No target specified. Running default POSTGRESQL_JOBS preset...");
        const queries = DATABASE_SEARCH_PRESETS.POSTGRESQL_JOBS;
        const discovered = await discoverTargets([...queries], limit);
        searchTargets.push(...discovered);
      }

      // 2. PostgreSQL Deduplication Check
      const newTargets: SearchResult[] = [];
      for (const target of searchTargets) {
        const exists = await isJobKnown(target.link);
        if (exists) {
          console.log(`⏩ Skipping target (Already stored in Postgres): ${target.link}`);
        } else {
          newTargets.push(target);
        }
      }

      console.log(`🎯 ${newTargets.length} new job targets remaining for scraping.`);

      // 3. Web Page Scraping via Firecrawl
      const scrapedPages: ScrapedPage[] = [...directPages];
      if (newTargets.length > 0) {
        const freshlyScraped = await scrapeBatch(newTargets, 2, 2000);
        scrapedPages.push(...freshlyScraped);
      }

      if (scrapedPages.length === 0) {
        console.log("⚠️ No new web pages scraped. Exiting.");
        await closePool();
        return;
      }

      // 4. Structured Data Extraction & Embedding Generation
      const jobPostings = await extractJobBatch(scrapedPages);

      // 5. Database Insertion into PostgreSQL
      let insertedCount = 0;
      for (const job of jobPostings) {
        const inserted = await insertJob(job);
        if (inserted) insertedCount++;
      }

      const totalJobs = await getJobCount();
      console.log(
        `\n✅ Ingestion complete! Successfully inserted ${insertedCount} new job posting(s).`
      );
      console.log(`📊 Total stored jobs in PostgreSQL database: ${totalJobs}\n`);
    } catch (err: any) {
      console.error("❌ Ingestion error:", err.message);
    } finally {
      await closePool();
    }
  });

/**
 * Keyword Search Command: Queries PostgreSQL using tsvector full-text search
 */
program
  .command("search-keyword")
  .description("Execute PostgreSQL Full-Text Keyword Search (tsvector)")
  .argument("<query>", "Search query term (e.g. 'PostgreSQL replication')")
  .option("-l, --limit <number>", "Max search results", "10")
  .action(async (queryTerm, options) => {
    console.log(`\n🔤 Executing PostgreSQL Full-Text Keyword Search for: "${queryTerm}"\n`);
    try {
      const startTime = performance.now();
      const results = await searchJobsKeyword(queryTerm, parseInt(options.limit, 10));
      const endTime = performance.now();

      console.log(`⚡ Query executed in ${(endTime - startTime).toFixed(2)} ms`);
      console.log(`🎯 Found ${results.length} matching result(s):\n`);

      results.forEach((item, index) => {
        console.log(`${index + 1}. [Rank: ${item.rank?.toFixed(4)}] ${item.title} @ ${item.company}`);
        console.log(`   Location: ${item.location || "N/A"}`);
        console.log(`   Skills: ${item.skills.join(", ")}`);
        console.log(`   URL: ${item.url}\n`);
      });
    } catch (err: any) {
      console.error("❌ Keyword search failed:", err.message);
    } finally {
      await closePool();
    }
  });

/**
 * Vector Search Command: Queries PostgreSQL using pgvector semantic search
 */
program
  .command("search-vector")
  .description("Execute PostgreSQL Semantic Vector Search (pgvector)")
  .argument("<query>", "Semantic search concept query (e.g. 'database high availability')")
  .option("-l, --limit <number>", "Max search results", "10")
  .action(async (queryTerm, options) => {
    console.log(`\n🧠 Executing PostgreSQL Semantic Vector Search for: "${queryTerm}"\n`);
    try {
      const startTime = performance.now();
      const queryEmbedding = await generateEmbedding(queryTerm);
      const results = await searchJobsVector(queryEmbedding, parseInt(options.limit, 10));
      const endTime = performance.now();

      console.log(`⚡ Query executed in ${(endTime - startTime).toFixed(2)} ms`);
      console.log(`🎯 Found ${results.length} matching result(s):\n`);

      results.forEach((item, index) => {
        console.log(`${index + 1}. [Cosine Distance: ${item.distance?.toFixed(4)}] ${item.title} @ ${item.company}`);
        console.log(`   Location: ${item.location || "N/A"}`);
        console.log(`   Skills: ${item.skills.join(", ")}`);
        console.log(`   URL: ${item.url}\n`);
      });
    } catch (err: any) {
      console.error("❌ Vector search failed:", err.message);
    } finally {
      await closePool();
    }
  });

/**
 * Benchmark Command: Side-by-side comparison of Full-Text vs. Semantic Search
 */
program
  .command("benchmark")
  .description("Run side-by-side comparison of Keyword vs. Semantic Vector Search")
  .argument("<query>", "Benchmark search prompt")
  .action(async (queryTerm) => {
    console.log(`\n⚖️  PERCONA BENCHMARK COMPARISON: "${queryTerm}"\n`);
    try {
      // 1. Keyword Search
      const kwStart = performance.now();
      const kwResults = await searchJobsKeyword(queryTerm, 5);
      const kwTime = (performance.now() - kwStart).toFixed(2);

      // 2. Vector Search
      const vecStart = performance.now();
      const queryEmbedding = await generateEmbedding(queryTerm);
      const vecResults = await searchJobsVector(queryEmbedding, 5);
      const vecTime = (performance.now() - vecStart).toFixed(2);

      console.log(`--------------------------------------------------`);
      console.log(`🔤 KEYWORD SEARCH (tsvector) [Latency: ${kwTime} ms]`);
      console.log(`--------------------------------------------------`);
      if (kwResults.length === 0) console.log("  No matches found.");
      kwResults.forEach((r, i) => console.log(`  ${i + 1}. ${r.title} @ ${r.company} (Rank: ${r.rank?.toFixed(4)})`));

      console.log(`\n--------------------------------------------------`);
      console.log(`🧠 SEMANTIC SEARCH (pgvector) [Latency: ${vecTime} ms]`);
      console.log(`--------------------------------------------------`);
      if (vecResults.length === 0) console.log("  No matches found.");
      vecResults.forEach((r, i) => console.log(`  ${i + 1}. ${r.title} @ ${r.company} (Distance: ${r.distance?.toFixed(4)})`));
      console.log(`\n--------------------------------------------------\n`);
    } catch (err: any) {
      console.error("❌ Benchmark failed:", err.message);
    } finally {
      await closePool();
    }
  });

program.parse(process.argv);
