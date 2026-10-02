# Semantic Job Search

A TypeScript job-ingestion and search API that compares PostgreSQL full-text search (`tsvector`) with semantic search using pgvector embeddings. It discovers job postings, extracts structured details, stores them in PostgreSQL, and exposes keyword, vector, and benchmark endpoints.

## What You Need

- Node.js 20 or newer and npm
- Docker Desktop, or a reachable PostgreSQL 18 database with pgvector
- API keys for SerpApi, Firecrawl, OpenRouter, and Jina

The default embedding model is `jina-embeddings-v5-omni-small`. Get a Jina API key at [jina.ai/embeddings](https://jina.ai/embeddings/).

## Quick Start

### 1. Clone and install

```bash
git clone https://github.com/DeraCodings/semantic_v_keyword_job_search.git
cd semantic_v_keyword_job_search
npm install
```

### 2. Configure environment variables

Create `.env` from the example:

```bash
cp .env.example .env
```

On Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

Set `SERPAPI_API_KEY`, `FIRECRAWL_API_KEY`, `OPENROUTER_API_KEY`, and `JINA_API_KEY` in `.env`. Keep this file private; it is excluded by `.gitignore`. Set the database URL to the local Compose database:

```dotenv
DATABASE_URL=postgresql://{user}:{your-password}@localhost:{PORT}/{container-name}
```
*`PORT` is your local machine or deployed PORT mapping to Postgres default `5432` PORT*

The credentials above match the local defaults in `docker/docker-composer.env`. Change both files together if you change those defaults.

### 3. Start PostgreSQL and create the schema

From the repository root, start the Percona PostgreSQL container:

```bash
docker compose --env-file docker/docker-composer.env -f docker/docker-compose.yml up -d
```

Connect to the database:

```bash
docker exec -it job_search psql -U admin -d job_search
```

Run this SQL once in `psql` to enable pgvector and create the table used by the application:

```sql
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS jobs (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  company TEXT NOT NULL,
  description TEXT NOT NULL,
  location TEXT,
  url TEXT NOT NULL UNIQUE,
  skills TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  embedding vector(1024)
);

CREATE OR REPLACE FUNCTION immutable_array_to_string(arr text[], sep text)
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$ SELECT array_to_string(arr, sep); $$;

ALTER TABLE jobs
ADD COLUMN IF NOT EXISTS search_vector tsvector
GENERATED ALWAYS AS (
  to_tsvector(
    'english',
    coalesce(title, '') || ' ' ||
    coalesce(description, '') || ' ' ||
    coalesce(immutable_array_to_string(skills, ' '), '')
  )
) STORED;

CREATE INDEX IF NOT EXISTS jobs_search_vector_idx
ON jobs USING GIN (search_vector);
```

**Embedding dimensions must match.** The database column is `vector(1024)` for the configured Jina model. The stored job embeddings and query embeddings must use the same model and output dimension. If you change embedding models, check that model's output dimension and update the database schema before ingesting or searching; do not mix vectors of different dimensions.

### 4. Start the API

```bash
npm run dev
```

The API listens at `http://localhost:3000` by default. Check that it can reach the database:

```text
http://localhost:3000/api/health
```

### 5. Ingest jobs and search

Ingest up to 10 results from the `DATA_ENGINEER` preset. Send this JSON body to `POST http://localhost:3000/api/jobs/ingest`:

```json
{
  "preset": "data_engineer",
  "limit": 10
}
```

For example, with curl:

```bash
curl -X POST http://localhost:3000/api/jobs/ingest \
  -H "Content-Type: application/json" \
  -d '{"preset":"data_engineer","limit":10}'
```

A successful response looks like this; counts vary by search results and existing database contents:

```json
{
  "success": true,
  "scrapedPagesCount": 10,
  "insertedCount": 5,
  "totalStoredJobs": 24
}
```

Search the ingested records with either engine:

```text
GET http://localhost:3000/api/search/vector?q=data%20engineer
GET http://localhost:3000/api/search/keyword?q=PostgreSQL
```

The vector endpoint calls Jina to embed the query, so it requires a valid Jina key. A search against an empty database returns no matching jobs; ingest records first.

## API Reference

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `GET` | `/api/health` | API status and stored job count |
| `POST` | `/api/jobs/ingest` | Discover, scrape, extract, embed, and store jobs |
| `GET` | `/api/search/keyword?q=<query>` | PostgreSQL full-text search |
| `GET` | `/api/search/vector?q=<query>` | Semantic search with pgvector |
| `GET` | `/api/benchmark?q=<query>` | Compare keyword and vector results |
| `GET` | `/api/debug/distances` | Diagnostic distances for built-in sample queries |

The ingest endpoint accepts one of `preset`, `query`, or `urls`, with an optional `limit`:

```json
{
  "preset": "data_engineer",
  "limit": 10
}
```

```json
{
  "query": "site:jobs.lever.co PostgreSQL engineer",
  "limit": 5
}
```

```json
{
  "urls": ["https://jobs.ashbyhq.com/company/job-id"]
}
```

Available presets: `POSTGRESQL_JOBS`, `DATABASE_ENGINEER`, `DATA_ENGINEER`, `BACKEND_DEVELOPER`, `INFRASTRUCTURE_ENGINEER`, `FRONTEND_DEVELOPER`, and `FULLSTACK_DEVELOPER`.

## Using an Existing PostgreSQL Database

Provide its connection string as `DATABASE_URL` in `.env`. The database must support pgvector, have the `vector` extension enabled, and contain the `jobs` table and `search_vector` generated column shown above. Ensure the database role has permission to create/use the extension and schema objects, or ask the database administrator to provision them.

## Project Map

- `src/index.ts`: Express API server and HTTP routes
- `src/index2.ts`: CLI for ingestion, keyword search, vector search, and benchmarking
- `src/services/`: search discovery, scraping, extraction, and embeddings
- `src/db/`: PostgreSQL connection and job queries
- `src/config/`: environment validation and search presets
- `docker/`: local PostgreSQL Compose configuration and environment values
- `test_samples/`: saved benchmark and distance-diagnosis response examples; these are reference snapshots, not database seed data

The CLI can be run with `npm run cli -- --help`. Other package scripts are `npm run build` to compile TypeScript and `npm start` to run the compiled API from `dist/`.

## Troubleshooting

- **`relation "jobs" does not exist` or missing `search_vector`:** run the schema SQL against the database named in `DATABASE_URL`.
- **`type "vector" does not exist`:** connect to the intended database and run `CREATE EXTENSION vector;`.
- **Vector dimension mismatch:** the `embedding` column dimension must equal the output dimension of the configured embedding model. Use the same model for stored and query embeddings.
- **API key errors or empty ingest:** verify the keys in `.env`; target discovery uses SerpApi, extraction uses OpenRouter, and embeddings use Jina. Firecrawl is used for scraping, with an HTTP fallback in the application.
- **Port conflict:** set `PORT` in `.env` to an available port.
