-- ==========================================
-- WARNING: This script will DELETE ALL DATA from the Quiz Bank tables.
-- It disables foreign key checks to allow truncating tables safely.
-- ==========================================

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE qb_exam_groups;
TRUNCATE TABLE qb_exam_questions;
TRUNCATE TABLE qb_exam_tags;
TRUNCATE TABLE qb_exams;

TRUNCATE TABLE qb_group_tags;
TRUNCATE TABLE qb_question_groups;
TRUNCATE TABLE qb_question_history;
TRUNCATE TABLE qb_question_tags;
TRUNCATE TABLE qb_questions;
TRUNCATE TABLE qb_tags;

-- Also clear submission tracking if you have mock submissions you want to reset
-- TRUNCATE TABLE qb_exam_submissions;

SET FOREIGN_KEY_CHECKS = 1;

-- After running this script, your database will be completely empty of questions and exams.
-- You can now safely run the `mock_exam_data.sql` script to properly seed the mock data!
