package com.groupone.backend.features.smarttest.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.features.quizbank.dto.QuestionResponse;
import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.enums.SkillType;
import com.groupone.backend.features.quizbank.repository.QuestionRepository;
import com.groupone.backend.features.smarttest.dto.SmartTestSubmitRequest;
import com.groupone.backend.features.smarttest.dto.SmartTestSubmitResponse;
import com.groupone.backend.features.smarttest.entity.UserQuestionAttempt;
import com.groupone.backend.features.smarttest.entity.UserTestSession;
import com.groupone.backend.features.smarttest.repository.UserQuestionAttemptRepository;
import com.groupone.backend.features.smarttest.repository.UserTestSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SmartTestService {

    private final QuestionRepository questionRepository;
    private final UserTestSessionRepository userTestSessionRepository;
    private final UserQuestionAttemptRepository userQuestionAttemptRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper;

    private User getCurrentUser() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof User) {
            return (User) principal;
        }
        
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("User not found: " + email));
    }

    @Transactional(readOnly = true)
    public List<QuestionResponse> generateSmartTest(String skillStr, String difficultyBand) {
        String normalizedBand = normalizeBand(difficultyBand);
        debugLog("Generating Smart Test: skill=" + skillStr + ", originalBand=" + difficultyBand + ", normalizedBand=" + normalizedBand);
        
        User user = getCurrentUser();
        SkillType skill = null;
        try {
            skill = SkillType.valueOf(skillStr.toUpperCase());
        } catch (Exception e) {
            debugLog("Invalid skill type: " + skillStr);
        }
        
        List<Question> questions = new ArrayList<>();
        int required = 15;

        if (skill != null) {
            // 1. Get IDs of questions the user already answered correctly to EXCLUDE them
            List<Long> solvedIds = userQuestionAttemptRepository.findCorrectQuestionIdsByUser(user.getId());
            if (solvedIds == null) solvedIds = new ArrayList<>();
            // If empty, pass null to the repository to trigger the (:excludeIds IS NULL) check in the native query
            List<Long> excludeIds = solvedIds.isEmpty() ? null : solvedIds;

            debugLog("Solved questions discovered: " + solvedIds.size() + ". Excluding them from generation pool.");

            // 2. Target weak areas (Weakness Correction)
            List<Long> weakTagIds = userQuestionAttemptRepository.findWeakTagIdsByUserAndSkill(
                    user.getId(), skill, PageRequest.of(0, 5));

            if (!weakTagIds.isEmpty()) {
                debugLog("Found weak tags: " + weakTagIds + ". Fetching targeted questions...");
                List<Question> weakQuestions = questionRepository.findRandomBySkillAndDifficultyAndTagsExcluding(
                        skill.name(), normalizedBand, weakTagIds, excludeIds, 10);
                questions.addAll(weakQuestions);
            }

            // 3. Fill the gap (Variety)
            int remaining = required - questions.size();
            if (remaining > 0) {
                debugLog("Fetching " + remaining + " remaining random questions for " + normalizedBand + " (excluding solved).");
                List<Question> randoms = questionRepository.findRandomBySkillAndDifficultyExcluding(
                        skill.name(), normalizedBand, excludeIds, required); 
                
                Set<Long> existingIds = questions.stream().map(Question::getId).collect(Collectors.toSet());
                for (Question q : randoms) {
                    if (questions.size() < required && !existingIds.contains(q.getId())) {
                        questions.add(q);
                    }
                }
            }
        }

        debugLog("Generated " + questions.size() + " questions.");
        return questions.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    private String normalizeBand(String band) {
        if (band == null) return "BAND_5_6";
        if (band.contains("0") && band.contains("4")) return "BAND_0_4";
        if (band.contains("5") && band.contains("6")) return "BAND_5_6";
        if (band.contains("7") && band.contains("8")) return "BAND_7_8";
        if (band.contains("9")) return "BAND_9";
        return "BAND_5_6";
    }

    private void debugLog(String message) {
        System.out.println("[SmartTestService] " + message);
    }

    @Transactional
    public SmartTestSubmitResponse submitSmartTest(SmartTestSubmitRequest request) {
        User user = getCurrentUser();
        String normalizedBand = normalizeBand(request.getDifficultyBand());
        
        long correctCount = request.getAttempts().stream().filter(a -> Boolean.TRUE.equals(a.getIsCorrect())).count();
        int total = request.getAttempts().size();
        Double score = total == 0 ? 0.0 : ((double) correctCount / total) * 10;
        
        UserTestSession session = UserTestSession.builder()
                .user(user)
                .startTime(LocalDateTime.now().minusMinutes(10)) 
                .endTime(LocalDateTime.now())
                .score(score)
                .skill(request.getSkill())
                .difficultyBand(normalizedBand)
                .testType("smart_test")
                .build();
                
        userTestSessionRepository.save(session);
        
        request.getAttempts().forEach(attempt -> {
            Question question = questionRepository.findById(attempt.getQuestionId())
                    .orElseThrow(() -> new RuntimeException("Question not found"));
                    
            UserQuestionAttempt uqa = UserQuestionAttempt.builder()
                    .user(user)
                    .session(session)
                    .question(question)
                    .userAnswer(attempt.getUserAnswer())
                    .isCorrect(attempt.getIsCorrect() != null ? attempt.getIsCorrect() : false)
                    .attemptDate(LocalDateTime.now())
                    .build();
            userQuestionAttemptRepository.save(uqa);
        });
        
        return SmartTestSubmitResponse.builder()
                .sessionId(session.getId())
                .correctCount((int) correctCount)
                .totalCount(total)
                .score(score)
                .build();
    }
    
    private QuestionResponse mapToResponse(Question q) {
        Map<String, Object> dataMap = null;
        try {
            if (q.getData() != null && !q.getData().isEmpty()) {
                dataMap = objectMapper.readValue(q.getData(), new TypeReference<Map<String, Object>>() {});
            }
        } catch (Exception ignored) {}

        return QuestionResponse.builder()
                .id(q.getId())
                .skill(q.getSkill())
                .type(q.getType())
                .difficultyBand(q.getDifficultyBand())
                .data(dataMap)
                .instruction(q.getInstruction())
                .explanation(q.getExplanation())
                .build();
    }
}
