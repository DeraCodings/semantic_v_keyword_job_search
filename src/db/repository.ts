import { query } from "./index.js";
import { JobPosting, SearchResultItem } from "../types/index.js";

/**
 * Inserts a new job posting into PostgreSQL.
 * Deduplicates automatically via UNIQUE constraint on the `url` column.
 */
export async function insertJob(job: JobPosting): Promise<boolean> {
  const sql = `
    INSERT INTO jobs (title, company, description, location, url, skills, embedding)
    VALUES ($1, $2, $3, $4, $5, $6, $7::vector)
    ON CONFLICT (url) DO NOTHING
    RETURNING id;
  `;

  const values = [
    job.title, // $1
    job.company, // $2
    job.description, // $3
    job.location || null, // $4
    job.url, // $5
    job.skills || [], // $6
    job.embedding ? JSON.stringify(job.embedding) : null, // $7
  ];

  const result = await query(sql, values);
  return (result.rowCount ?? 0) > 0;
}

/**
 * Checks if a job URL already exists in PostgreSQL
 */
export async function isJobKnown(url: string): Promise<boolean> {
  const result = await query("SELECT 1 FROM jobs WHERE url = $1 LIMIT 1", [url]);
  return (result.rowCount ?? 0) > 0;
}

/**
 * Performs PostgreSQL Keyword / Full-Text Search using `search_vector @@ websearch_to_tsquery()`
 * and ranks results with `ts_rank_cd()`.
 */
export async function searchJobsKeyword(
  searchQuery: string,
  limit: number = 10
): Promise<SearchResultItem[]> {
  const sql = `
    SELECT 
      id, 
      title, 
      company, 
      description, 
      location, 
      url, 
      skills,
      ts_rank_cd(search_vector, websearch_to_tsquery('english', $1)) AS rank
    FROM jobs
    WHERE search_vector @@ websearch_to_tsquery('english', $1)
    ORDER BY rank DESC
    LIMIT $2;
  `;

  const result = await query(sql, [searchQuery, limit]);
  return result.rows.map((row) => ({
    id: row.id,
    title: row.title,
    company: row.company,
    description: row.description,
    location: row.location,
    url: row.url,
    skills: row.skills,
    rank: parseFloat(row.rank),
  }));
}

/**
 * Performs pgvector Semantic Search using cosine distance operator `<=>`
 */
export async function searchJobsVector(
  embedding: number[] | null,
  limit: number = 10,
  maxDistance: number = 0.42 // absolute ceiling
): Promise<SearchResultItem[]> {
  const sql = `
    SELECT 
      id, 
      title, 
      company, 
      description, 
      location, 
      url, 
      skills,
      (embedding <=> $1::vector) AS distance
    FROM jobs
    WHERE embedding IS NOT NULL
      AND (embedding <=> $1::vector) < $3 -- Optional threshold for similarity
    ORDER BY distance ASC
    LIMIT $2;
  `;

  const result = await query(sql, [JSON.stringify(embedding), limit, maxDistance]);
  const rows = result.rows.map((row) => ({
    id: row.id,
    title: row.title,
    company: row.company,
    description: row.description,
    location: row.location,
    url: row.url,
    skills: row.skills,
    distance: parseFloat(row.distance),
  }));

  // Relative tightening: keep only rows close to the best match
  if (rows.length === 0) return [];

  const bestDistance = rows[0].distance;
  const ceilingDistance = Math.min(bestDistance * 1.25, maxDistance); // Allow some leeway but not exceed maxDistance
  return rows.filter((row) => row.distance <= ceilingDistance);
}

/**
 * Returns total count of stored job postings in PostgreSQL
 */
export async function getJobCount(): Promise<number> {
  const result = await query("SELECT COUNT(*) FROM jobs");
  return parseInt(result.rows[0].count, 10);
}
