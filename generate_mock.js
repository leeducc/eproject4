const fs = require('fs');

const TYPES = ['MULTIPLE_CHOICE', 'FILL_BLANK', 'MATCHING'];

const getMcData = () => JSON.stringify({
    options: [
        { id: "a", label: "Option A" },
        { id: "b", label: "Option B" },
        { id: "c", label: "Option C" },
        { id: "d", label: "Option D" }
    ],
    correct_ids: ["b"],
    multiple_select: false
});

const getFbData = () => JSON.stringify({
    template: "The [blank1] brown fox jumps over the lazy [blank2].",
    blanks: {
        "[blank1]": { correct: ["quick", "fast"], max_words: 1 },
        "[blank2]": { correct: ["dog", "canine"], max_words: 1 }
    },
    answer_pool: ["cat", "slow", "mouse"]
});

const getMatchingData = () => JSON.stringify({
    left_items: [
        { id: "1", text: "Item 1" },
        { id: "2", text: "Item 2" }
    ],
    right_items: [
        { id: "A", text: "Match A" },
        { id: "B", text: "Match B" },
        { id: "C", text: "Match C" }
    ],
    solution: { "1": "B", "2": "A" }
});

const getData = (type) => {
    switch (type) {
        case 'MULTIPLE_CHOICE': return getMcData();
        case 'FILL_BLANK': return getFbData();
        case 'MATCHING': return getMatchingData();
    }
}

let sql = `
-- Generated Mock Data
SET FOREIGN_KEY_CHECKS=0;

-- 1. Exams
INSERT INTO qb_exams (title, exam_type, description, created_at) VALUES 
('Full Mock Exam - Standard', 'IELTS', 'A standard mock exam placeholder.', NOW()),
('Real Exam - Official', 'REAL_EXAM', 'A real exam placeholder.', NOW());
SET @mock_exam = LAST_INSERT_ID();
SET @real_exam = @mock_exam + 1;

`;

let groupIdOffset = 1;
let questionIdOffset = 1;

function generateExam(examVarName, examPrefix, authorId) {
    
    for (let p = 1; p <= 4; p++) {
        sql += `\n-- LISTENING Part ${p} for ${examPrefix}\n`;
        sql += `INSERT INTO qb_question_groups (skill, title, content, difficulty_band, author_id, created_at) VALUES ('LISTENING', '${examPrefix} - LISTENING Part ${p}', 'Placeholder audio transcript for LISTENING part ${p}...', 'BAND_5_6', ${authorId}, NOW());\n`;
        sql += `SET @group_${groupIdOffset} = LAST_INSERT_ID();\n`;
        sql += `INSERT INTO qb_exam_groups (exam_id, group_id) VALUES (${examVarName}, @group_${groupIdOffset});\n`;
        
        for (let q = 1; q <= 10; q++) {
            const type = TYPES[(q - 1) % TYPES.length];
            const instruction = `Q${q}: Answer this ${type} question for LISTENING Part ${p}.`;
            const data = getData(type);
            
            sql += `INSERT INTO qb_questions (skill, type, difficulty_band, instruction, data, is_premium_content, author_id, group_id) VALUES ('LISTENING', '${type}', 'BAND_5_6', '${instruction}', '${data}', false, ${authorId}, @group_${groupIdOffset});\n`;
        }
        groupIdOffset++;
    }

    
    const readingQCounts = [13, 13, 14];
    for (let p = 1; p <= 3; p++) {
        sql += `\n-- READING Part ${p} for ${examPrefix}\n`;
        sql += `INSERT INTO qb_question_groups (skill, title, content, difficulty_band, author_id, created_at) VALUES ('READING', '${examPrefix} - READING Part ${p}', 'Placeholder content for READING passage ${p}...', 'BAND_5_6', ${authorId}, NOW());\n`;
        sql += `SET @group_${groupIdOffset} = LAST_INSERT_ID();\n`;
        sql += `INSERT INTO qb_exam_groups (exam_id, group_id) VALUES (${examVarName}, @group_${groupIdOffset});\n`;
        
        const qCount = readingQCounts[p - 1];
        for (let q = 1; q <= qCount; q++) {
            const type = TYPES[(q - 1) % TYPES.length];
            const instruction = `Q${q}: Answer this ${type} question for READING Part ${p}.`;
            const data = getData(type);
            
            sql += `INSERT INTO qb_questions (skill, type, difficulty_band, instruction, data, is_premium_content, author_id, group_id) VALUES ('READING', '${type}', 'BAND_5_6', '${instruction}', '${data}', false, ${authorId}, @group_${groupIdOffset});\n`;
        }
        groupIdOffset++;
    }

    
    sql += `\n-- Writing Tasks for ${examPrefix}\n`;
    for(let t = 1; t <= 2; t++) {
       sql += `INSERT INTO qb_questions (skill, type, difficulty_band, instruction, data, is_premium_content, author_id) VALUES ('WRITING', 'ESSAY', 'BAND_5_6', 'Writing Task ${t} for ${examPrefix}: Discuss...', '{}', false, ${authorId});\n`;
       sql += `SET @writing_${examPrefix.replace(/[^a-zA-Z]/g, '')}_${t} = LAST_INSERT_ID();\n`;
       sql += `INSERT INTO qb_exam_questions (exam_id, question_id) VALUES (${examVarName}, @writing_${examPrefix.replace(/[^a-zA-Z]/g, '')}_${t});\n`;
    }
}

generateExam('@mock_exam', 'Mock Test', 5);
generateExam('@real_exam', 'Real Test', 5);

sql += `\nSET FOREIGN_KEY_CHECKS=1;\n`;

fs.writeFileSync('d:/project/eproject4/mock_exam_data.sql', sql, 'utf8');
console.log('SQL generated successfully.');
