-- Add FULLTEXT index for full-text search capability
ALTER TABLE qb_questions ADD FULLTEXT INDEX idx_question_search (data, instruction, explanation);
