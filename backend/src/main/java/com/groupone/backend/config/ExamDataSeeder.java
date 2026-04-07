package com.groupone.backend.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.features.quizbank.entity.Exam;
import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.entity.QuestionGroup;
import com.groupone.backend.features.quizbank.entity.Tag;
import com.groupone.backend.features.quizbank.enums.DifficultyBand;
import com.groupone.backend.features.quizbank.enums.ExamType;
import com.groupone.backend.features.quizbank.enums.QuestionType;
import com.groupone.backend.features.quizbank.enums.SkillType;
import com.groupone.backend.features.quizbank.repository.ExamRepository;
import com.groupone.backend.features.quizbank.repository.QuestionGroupRepository;
import com.groupone.backend.features.quizbank.repository.QuestionRepository;
import com.groupone.backend.features.quizbank.repository.TagRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

@Component
@Order(2) 
@RequiredArgsConstructor
@Slf4j
public class ExamDataSeeder implements CommandLineRunner {

    private final ExamRepository examRepository;
    private final QuestionRepository questionRepository;
    private final QuestionGroupRepository questionGroupRepository;
    private final TagRepository tagRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper;

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        
        if (examRepository.count() > 0) {
            log.info("[ExamDataSeeder] Exam data already exists. Skipping re-seeding to preserve stable IDs.");
            return;
        }

        log.info("[ExamDataSeeder] No exam data found. Starting to seed exam sample data with IELTS requirements...");

        
        User admin = userRepository.findByEmail("admin@englishhub.com")
                .orElseThrow(() -> new RuntimeException("Admin user not found. Run DataSeeder first."));
        Long authorId = admin.getId();

        
        Tag ieltsTag = getOrCreateTag("IELTS", "exam_format");
        Tag academicTag = getOrCreateTag("Academic", "exam_type");
        List<Tag> tags = List.of(ieltsTag, academicTag);

        List<QuestionGroup> allGroups = new ArrayList<>();
        List<Question> standaloneQuestions = new ArrayList<>();

        
        int[] readingQCounts = {13, 13, 14};
        for (int i = 0; i < 3; i++) {
            QuestionGroup group = QuestionGroup.builder()
                    .skill(SkillType.READING)
                    .title("Reading Passage " + (i + 1) + " Placeholder")
                    .content("IELTS Reading Passage Content Placeholder " + (i + 1) + ". " + 
                             "This is a repeat placeholder text used for testing exam composition and validation logic. ".repeat(10))
                    .difficultyBand(DifficultyBand.BAND_7_8)
                    .authorId(authorId)
                    .createdAt(LocalDateTime.now())
                    .tags(tags)
                    .build();
            group = questionGroupRepository.save(group);
            allGroups.add(group);

            for (int q = 0; q < readingQCounts[i]; q++) {
                createMCQ(group, SkillType.READING, DifficultyBand.BAND_7_8, 
                        "Reading Q" + (q + 1) + " for Passage " + (i + 1), "Explanation placeholder", 
                        List.of("Option A", "Option B", "Option C", "Option D"), List.of("1"), authorId, tags);
            }
        }

        
        for (int i = 0; i < 4; i++) {
            QuestionGroup group = QuestionGroup.builder()
                    .skill(SkillType.LISTENING)
                    .title("Listening Section " + (i + 1) + " Placeholder")
                    .content("IELTS Listening Script Placeholder " + (i + 1) + ". " + 
                             "This text represents the audio transcript for testing purposes. ".repeat(5))
                    .mediaUrl("placeholder_audio_" + (i + 1) + ".mp3")
                    .mediaType("audio/mpeg")
                    .difficultyBand(DifficultyBand.BAND_5_6)
                    .authorId(authorId)
                    .createdAt(LocalDateTime.now())
                    .tags(tags)
                    .build();
            group = questionGroupRepository.save(group);
            allGroups.add(group);

            for (int q = 0; q < 10; q++) {
                createMCQ(group, SkillType.LISTENING, DifficultyBand.BAND_5_6, 
                        "Listening Q" + (q + 1) + " for Section " + (i + 1), "Explanation placeholder", 
                        List.of("Choice 1", "Choice 2", "Choice 3", "Choice 4"), List.of("2"), authorId, tags);
            }
        }

        
        for (DifficultyBand band : DifficultyBand.values()) {
            for (int i = 0; i < 2; i++) {
                createEssay(null, SkillType.WRITING, band, 
                        "[" + band + "] IELTS Writing Task " + (i + 1) + " prompt. Discuss the following topic...", 
                        "Task " + (i + 1) + " marking criteria for " + band, authorId, tags);
            }
        }

        
        Exam ieltsExam = Exam.builder()
                .title("Full IELTS Mock Test - Automated Seed")
                .examType(ExamType.IELTS)
                .description("Complete IELTS Academic format including 3 Reading passages, 4 Listening sections, and 2 Writing tasks.")
                .groups(allGroups)
                .questions(standaloneQuestions)
                .tags(tags)
                .createdAt(LocalDateTime.now())
                .build();
        
        examRepository.save(ieltsExam);

        log.info("[ExamDataSeeder] Detailed IELTS sample data seeded: 3 Reading (40Q), 4 Listening (40Q), 2 Writing.");
    }

    private Tag getOrCreateTag(String name, String namespace) {
        return tagRepository.findByNameAndNamespace(name, namespace)
                .orElseGet(() -> tagRepository.save(Tag.builder()
                        .name(name)
                        .namespace(namespace)
                        .build()));
    }

    private Question createMCQ(QuestionGroup group, SkillType skill, DifficultyBand band, String instruction, String explanation, List<String> optionLabels, List<String> correctIds, Long authorId, List<Tag> tags) throws Exception {
        List<Map<String, Object>> options = new ArrayList<>();
        for (int i = 0; i < optionLabels.size(); i++) {
            options.add(Map.of("id", String.valueOf(i + 1), "label", optionLabels.get(i)));
        }

        Map<String, Object> data = new HashMap<>();
        data.put("options", options);
        data.put("correct_ids", correctIds);
        data.put("multiple_select", correctIds.size() > 1);
        data.put("answer_with_image", false);

        Question q = Question.builder()
                .group(group)
                .skill(skill)
                .type(QuestionType.MULTIPLE_CHOICE)
                .difficultyBand(band)
                .instruction(instruction)
                .explanation(explanation)
                .data(objectMapper.writeValueAsString(data))
                .authorId(authorId)
                .tags(tags)
                .build();
        return questionRepository.save(q);
    }

    private Question createFillBlank(QuestionGroup group, SkillType skill, DifficultyBand band, String template, String explanation, Map<String, Object> blanks, Long authorId, List<Tag> tags) throws Exception {
        Map<String, Object> data = new HashMap<>();
        data.put("template", template);
        data.put("blanks", blanks);

        Question q = Question.builder()
                .group(group)
                .skill(skill)
                .type(QuestionType.FILL_BLANK)
                .difficultyBand(band)
                .instruction("Fill in the blanks with appropriate words from the text.")
                .explanation(explanation)
                .data(objectMapper.writeValueAsString(data))
                .authorId(authorId)
                .tags(tags)
                .build();
        return questionRepository.save(q);
    }

    private Question createMatching(QuestionGroup group, SkillType skill, DifficultyBand band, String instruction, String explanation, List<String> leftTexts, List<String> rightTexts, Map<String, String> solution, Long authorId, List<Tag> tags) throws Exception {
        List<Map<String, Object>> leftItems = new ArrayList<>();
        for (int i = 0; i < leftTexts.size(); i++) {
            leftItems.add(Map.of("id", "L" + i, "text", leftTexts.get(i)));
        }

        List<Map<String, Object>> rightItems = new ArrayList<>();
        for (int i = 0; i < rightTexts.size(); i++) {
            rightItems.add(Map.of("id", "R" + i, "text", rightTexts.get(i)));
        }

        Map<String, Object> data = new HashMap<>();
        data.put("left_items", leftItems);
        data.put("right_items", rightItems);
        data.put("solution", solution);

        Question q = Question.builder()
                .group(group)
                .skill(skill)
                .type(QuestionType.MATCHING)
                .difficultyBand(band)
                .instruction(instruction)
                .explanation(explanation)
                .data(objectMapper.writeValueAsString(data))
                .authorId(authorId)
                .tags(tags)
                .build();
        return questionRepository.save(q);
    }

    private Question createEssay(QuestionGroup group, SkillType skill, DifficultyBand band, String instruction, String explanation, Long authorId, List<Tag> tags) throws Exception {
        Map<String, Object> data = new HashMap<>();
        data.put("type", "ESSAY");

        Question q = Question.builder()
                .group(group)
                .skill(skill)
                .type(QuestionType.ESSAY)
                .difficultyBand(band)
                .instruction(instruction)
                .explanation(explanation)
                .data(objectMapper.writeValueAsString(data))
                .authorId(authorId)
                .tags(tags)
                .build();
        return questionRepository.save(q);
    }
}
