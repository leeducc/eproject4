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
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("User not found"));
    }

    @Transactional(readOnly = true)
    public List<QuestionResponse> generateSmartTest(String skillStr, String difficultyBand) {
        User user = getCurrentUser();
        SkillType skill = null;
        try {
            skill = SkillType.valueOf(skillStr.toUpperCase());
        } catch (Exception e) {
            // fallback if null or invalid
        }
        
        List<Question> questions = new ArrayList<>();
        int required = 15;

        if (skill != null) {
            List<Long> weakTagIds = userQuestionAttemptRepository.findWeakTagIdsByUserAndSkill(
                    user.getId(), skill, PageRequest.of(0, 5));

            if (!weakTagIds.isEmpty()) {
                List<Question> weakQuestions = questionRepository.findRandomBySkillAndDifficultyAndTags(
                        skill.name(), difficultyBand, weakTagIds, 10);
                questions.addAll(weakQuestions);
            }

            int remaining = required - questions.size();
            if (remaining > 0) {
                List<Question> randoms = questionRepository.findRandomBySkillAndDifficulty(
                        skill.name(), difficultyBand, required); // fetch max required just in case of dupes
                
                Set<Long> existingIds = questions.stream().map(Question::getId).collect(Collectors.toSet());
                for (Question q : randoms) {
                    if (questions.size() < required && !existingIds.contains(q.getId())) {
                        questions.add(q);
                    }
                }
            }
        } else {
            // fallback generic fetch
        }

        return questions.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Transactional
    public SmartTestSubmitResponse submitSmartTest(SmartTestSubmitRequest request) {
        User user = getCurrentUser();
        
        long correctCount = request.getAttempts().stream().filter(a -> Boolean.TRUE.equals(a.getIsCorrect())).count();
        int total = request.getAttempts().size();
        Double score = total == 0 ? 0.0 : ((double) correctCount / total) * 10;
        
        UserTestSession session = UserTestSession.builder()
                .user(user)
                .startTime(LocalDateTime.now().minusMinutes(10)) // Mock 10 min past start
                .endTime(LocalDateTime.now())
                .score(score)
                .skill(request.getSkill())
                .difficultyBand(request.getDifficultyBand())
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
