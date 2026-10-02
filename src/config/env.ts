import dotenv from "dotenv";
import { z } from "zod";

dotenv.config();

/**
 * Environment variables validation schema using Zod
 */
const envSchema = z.object({
  SERPAPI_API_KEY: z.string().default("dummy_serpapi_key"),
  FIRECRAWL_API_KEY: z.string().default("dummy_firecrawl_key"),
  OPENROUTER_API_KEY: z.string().default("dummy_openrouter_key"),
  OPENROUTER_MODEL: z
    .string()
    .default("openrouter/free"),
  DATABASE_URL: z
    .string()
    .default("postgresql://admin:mysecretpassword@localhost:5431/job_search"),
  JINA_API_KEY: z.string().default("dummy_jina_api_key"),
  JINA_EMBEDDING_MODEL: z.string().default("jina-embeddings-v5-omni-small"),
});

const parseConfig = () => {
  const result = envSchema.safeParse(process.env);

  if (!result.success) {
    console.error("❌ Invalid environment variables:");
    console.error(result.error.flatten().fieldErrors);
    process.exit(1);
  }

  return result.data;
};

export const config = parseConfig();
export type Config = z.infer<typeof envSchema>;
