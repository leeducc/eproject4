---
trigger: always_on
---

# Rules for AI File Edits
- Always use LF (Unix) line endings in code blocks.
- When performing a search-and-replace edit, ensure the search block is an exact, literal match of the existing code.
- If an edit fails twice, provide the full file content instead of a partial diff.
- Do not omit code with comments like "// ... existing code ..." unless specifically asked; provide the full block to avoid malformed edits.
- Ensure all brackets and braces are balanced within the edit block.