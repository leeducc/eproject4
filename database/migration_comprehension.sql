-- Migration script for Comprehension/Passage-based questions

-- 1. Create Question Groups table
CREATE TABLE IF NOT EXISTS qb_question_groups (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    skill VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    media_url VARCHAR(255),
    media_type VARCHAR(50),
    difficulty_band VARCHAR(50) NOT NULL,
    author_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Add group_id column to Questions table
ALTER TABLE qb_questions ADD COLUMN group_id BIGINT;

-- 3. Add foreign key constraint
ALTER TABLE qb_questions 
ADD CONSTRAINT fk_question_group 
FOREIGN KEY (group_id) REFERENCES qb_question_groups(id) 
ON DELETE SET NULL;
