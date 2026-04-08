## 📚 Section 10: Vocabulary Builder (Mobile)

### 10.1 Word Dashboard & Search

A searchable list of words with AI-generated definitions and examples.

- **API Calls**:
  - `GET /api/v1/vocabulary`: List of words with pagination.
  - `GET /api/v1/vocabulary/{word}/details`: Fetches AI definitions and synonyms.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `vocabulary_entity` | `id` | BIGINT | PK |
  | `vocabulary_entity` | `word` | VARCHAR | The term being learned |
  | `vocabulary_entity` | `level_group` | VARCHAR | Beginner, Intermediate, Advanced |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant App as Mobile App
      participant API as Spring Boot API
      participant AI as Ollama (Gemma)
      App->>API: GET /api/v1/vocabulary/serendipity/details
      API->>AI: Fetch definition from context
      AI-->>API: Definition, Example, Synonyms
      API-->>App: Word Detail Page
  ```

- **UI Design**: [IMAGE_PLACEHOLDER: VOCABULARY_SEARCH_LIST]
