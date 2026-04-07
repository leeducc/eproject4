-- seed_smart_test.sql
-- Compatible with MySQL (eproject4 database)
-- Author ID: 5
-- Enum Values: BAND_0_4, BAND_5_6, BAND_7_8, BAND_9

SET FOREIGN_KEY_CHECKS=0;

-- 1. Ensure Tags Exist
INSERT IGNORE INTO qb_tags (name, namespace, color) VALUES 
('Level1_MULTIPLE_CHOICE', 'skill_type', '#4CAF50'),
('Level1_FIB', 'skill_type', '#2196F3'),
('Level1_match', 'skill_type', '#FF9800'),
('Level2_MULTIPLE_CHOICE', 'skill_type', '#4CAF50'),
('Level2_FIB', 'skill_type', '#2196F3'),
('Level2_match', 'skill_type', '#FF9800');

-- 2. LISTENING Questions
-- BAND_0_4
INSERT INTO qb_questions (skill, type, difficulty_band, instruction, data, is_premium_content, author_id, is_active) VALUES 
('LISTENING', 'MULTIPLE_CHOICE', 'BAND_0_4', 'Nghe đoạn hội thoại và chọn đáp án đúng về giờ hẹn.', '{"options": [{"id": "a", "label": "10:30 AM"}, {"id": "b", "label": "11:00 AM"}, {"id": "c", "label": "11:30 AM"}], "correct_ids": ["b"], "multiple_select": false}', 0, 5, 1),
('LISTENING', 'FILL_BLANK', 'BAND_0_4', 'Điền vào chỗ trống tên của người gọi điện.', '{"template": "Tên khách hàng là [blank1].", "blanks": {"[blank1]": {"correct": ["John Smith", "John"], "max_words": 2}}}', 0, 5, 1),
('LISTENING', 'MATCHING', 'BAND_0_4', 'Nối tên nhân viên với nhiệm vụ tương ứng.', '{"left_items": [{"id": "1", "text": "Anna"}, {"id": "2", "text": "Peter"}], "right_items": [{"id": "A", "text": "Pha cà phê"}, {"id": "B", "text": "Đón khách"}, {"id": "C", "text": "Dọn dẹp"}], "solution": {"1": "B", "2": "A"}}', 0, 5, 1);

-- BAND_5_6
INSERT INTO qb_questions (skill, type, difficulty_band, instruction, data, is_premium_content, author_id, is_active) VALUES 
('LISTENING', 'MULTIPLE_CHOICE', 'BAND_5_6', 'What is the main reason for the construction?', '{"options": [{"id": "a", "label": "New library"}, {"id": "b", "label": "Sports center"}, {"id": "c", "label": "Student dorm"}], "correct_ids": ["c"], "multiple_select": false}', 0, 5, 1),
('LISTENING', 'FILL_BLANK', 'BAND_5_6', 'Complete the notes with ONE WORD ONLY.', '{"template": "The project will start in [blank1].", "blanks": {"[blank1]": {"correct": ["September", "Sept"], "max_words": 1}}}', 0, 5, 1);

-- 3. READING Questions
-- BAND_0_4
INSERT INTO qb_questions (skill, type, difficulty_band, instruction, data, is_premium_content, author_id, is_active) VALUES 
('READING', 'MULTIPLE_CHOICE', 'BAND_0_4', 'Đọc đoạn văn và chọn tiêu đề phù hợp.', '{"options": [{"id": "a", "label": "Một ngày ở nông trại"}, {"id": "b", "label": "Chuyến đi biển"}, {"id": "c", "label": "Thành phố nhộn nhịp"}], "correct_ids": ["a"], "multiple_select": false}', 0, 5, 1),
('READING', 'FILL_BLANK', 'BAND_0_4', 'Hoàn thành câu dựa trên thông tin bài đọc.', '{"template": "Con mèo đang ngủ trên [blank1].", "blanks": {"[blank1]": {"correct": ["ghế", "sofa"], "max_words": 1}}}', 0, 5, 1);

-- BAND_7_8
INSERT INTO qb_questions (skill, type, difficulty_band, instruction, data, is_premium_content, author_id, is_active) VALUES 
('READING', 'MULTIPLE_CHOICE', 'BAND_7_8', 'According to the passage, the implementation of AI...', '{"options": [{"id": "a", "label": "Is inevitable"}, {"id": "b", "label": "Is controversial"}, {"id": "c", "label": "Is redundant"}], "correct_ids": ["b"], "multiple_select": false}', 0, 5, 1),
('READING', 'FILL_BLANK', 'BAND_7_8', 'The researcher noted that the [blank1] of the data played a pivotal role.', '{"template": "The researcher noted that the [blank1] of the data played a pivotal role.", "blanks": {"[blank1]": {"correct": ["accuracy", "precision"], "max_words": 1}}}', 0, 5, 1);

-- 4. Associate Questions with Tags (Mapping Level 1 tags to BAND_0_4 questions)
INSERT IGNORE INTO qb_question_tags (question_id, tag_id) 
SELECT q.id, t.id FROM qb_questions q, qb_tags t 
WHERE q.difficulty_band = 'BAND_0_4' AND t.name = 'Level1_MULTIPLE_CHOICE' AND q.type = 'MULTIPLE_CHOICE';

INSERT IGNORE INTO qb_question_tags (question_id, tag_id) 
SELECT q.id, t.id FROM qb_questions q, qb_tags t 
WHERE q.difficulty_band = 'BAND_0_4' AND t.name = 'Level1_FIB' AND q.type = 'FILL_BLANK';

INSERT IGNORE INTO qb_question_tags (question_id, tag_id) 
SELECT q.id, t.id FROM qb_questions q, qb_tags t 
WHERE q.difficulty_band = 'BAND_0_4' AND t.name = 'Level1_match' AND q.type = 'MATCHING';

-- 5. Build mock performance data for User ID 1
INSERT IGNORE INTO user_test_sessions (user_id, start_time, end_time, score, skill, difficulty_band, test_type)
VALUES (1, NOW(), NOW(), 2.0, 'LISTENING', 'BAND_0_4', 'smart_test');
SET @session_id = LAST_INSERT_ID();

INSERT IGNORE INTO user_question_attempts (user_id, session_id, question_id, user_answer, is_correct, attempt_date)
SELECT 1, @session_id, q.id, 'Wrong Answer', 0, NOW()
FROM qb_questions q WHERE q.type = 'FILL_BLANK' AND q.difficulty_band = 'BAND_0_4' LIMIT 3;

SET FOREIGN_KEY_CHECKS=1;
