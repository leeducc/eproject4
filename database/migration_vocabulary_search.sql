-- Migration to add Full-Text Search and History Tracking for Vocabulary

-- Add Full-Text index to vocabulary table
ALTER TABLE vocabulary ADD FULLTEXT INDEX idx_vocab_search (word, definition);

-- History tables will be created automatically by Hibernate if ddl-auto=update is set,
-- but here are the manual creation scripts for reference:

/*
CREATE TABLE IF NOT EXISTS vocabulary_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vocabulary_id BIGINT NOT NULL,
    editor_id BIGINT NOT NULL,
    action VARCHAR(255) NOT NULL,
    snapshot TEXT,
    changes TEXT,
    created_at DATETIME NOT NULL
);

CREATE TABLE IF NOT EXISTS vocabulary_practice_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    practice_id BIGINT NOT NULL,
    editor_id BIGINT NOT NULL,
    action VARCHAR(255) NOT NULL,
    snapshot TEXT,
    changes TEXT,
    created_at DATETIME NOT NULL
);
*/
