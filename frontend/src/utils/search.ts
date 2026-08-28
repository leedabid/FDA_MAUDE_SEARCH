/**
 * Multi-word search matching utility
 * 
 * Rules:
 * 1. Comma (,) or Pipe (|) -> OR search (e.g. "g6, g7" matches items with "g6" OR "g7")
 * 2. Spaces ( ) -> AND search (e.g. "dexcom sensor" matches items containing BOTH "dexcom" AND "sensor")
 * 3. Double quotes ("...") -> Exact phrase match (e.g. '"g7 sensor"')
 */
export function matchMultiWordSearch(targetText: string, query: string): boolean {
  if (!query || !query.trim()) return true;
  if (!targetText) return false;

  const target = targetText.toLowerCase();
  const trimmedQuery = query.trim().toLowerCase();

  // Split by OR operators: comma (,) or pipe (|)
  const orClauses = trimmedQuery
    .split(/[,|]/)
    .map((c) => c.trim())
    .filter((c) => c.length > 0);

  if (orClauses.length === 0) return true;

  // Match if ANY of the OR clauses evaluate to true
  return orClauses.some((clause) => {
    // Extract quoted exact phrases
    const phrases: string[] = [];
    const unquoted = clause.replace(/"([^"]+)"/g, (_, p1) => {
      phrases.push(p1.trim());
      return "";
    });

    // Check exact phrases (must all match)
    for (const phrase of phrases) {
      if (phrase && !target.includes(phrase)) {
        return false;
      }
    }

    // Split remaining terms by whitespace (AND condition)
    const terms = unquoted
      .split(/\s+/)
      .map((t) => t.trim())
      .filter((t) => t.length > 0);

    // All terms in this clause must be present in target
    return terms.every((term) => target.includes(term));
  });
}
