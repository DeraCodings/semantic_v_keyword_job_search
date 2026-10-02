import pg from "pg";
import { config } from "../config/env.js";

const { Pool } = pg;

let poolEnded = false;

/**
 * PostgreSQL Connection Pool configured for Percona PostgreSQL 18 container
 */
export const pool = new Pool({
	connectionString: config.DATABASE_URL,
});

/**
 * Executes a parameterized SQL query against PostgreSQL
 */
export async function query<T extends pg.QueryResultRow = any>(text: string, params?: any[]): Promise<pg.QueryResult<T>> {
	return await pool.query<T>(text, params);
}

/**
 * Closes the PostgreSQL connection pool gracefully
 */
export async function closePool(): Promise<void> {
	if (!poolEnded) {
		poolEnded = true;
		await pool.end();
	}
}
