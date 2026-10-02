import { config } from "../config/env.js";
import { retryWithBackoff } from "../utils/rate-limiter.js";

const JINA_EMBEDDINGS_URL = "https://api.jina.ai/v1/embeddings";

/**
 * Generates a high-precision vector embedding for input text using Jina Embedding API.
 */

export async function generateEmbedding(text: string): Promise<number[] | null> {
  if (!text || text.trim().length === 0) {
    throw new Error("Cannot generate embedding for empty text");
  }

  try {
    const responseText = await retryWithBackoff(async () => {
      const response = await fetch(JINA_EMBEDDINGS_URL, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${config.JINA_API_KEY}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: config.JINA_EMBEDDING_MODEL,
          input: text,
        }),
      });

      if (!response.ok) {
        const errText = await response.text();
        throw new Error(`Jina AI Embedding API error (${response.status}): ${errText}`);
      }

      return await response.json();
    });

    const embeddingVector = responseText?.data?.[0]?.embedding;
    if (Array.isArray(embeddingVector) && embeddingVector.length > 0) {
      console.log(
        `🧠 Generated Jina vector embedding (${embeddingVector.length} dimensions)`
      );
      console.log(
        `First 15 embedding values: ${embeddingVector.slice(0, 15).join(" ")}`
      );
      return embeddingVector;
    }

    throw new Error("Jina returned an empty or malformed embedding");
  } catch (error: any) {
    console.warn(`⚠️ Jina AI embedding API failed (${error.message})`);
    throw new Error(`Embedding generation failed: ${error.message}`);
  }
}