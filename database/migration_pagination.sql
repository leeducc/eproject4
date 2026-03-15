-- Migration to add composite index for keyset pagination on questions
-- Target: (skill, type, difficulty_band, id) to cover primary filters

CREATE INDEX idx_questions_pagination ON qb_questions (skill, type, difficulty_band, id);
