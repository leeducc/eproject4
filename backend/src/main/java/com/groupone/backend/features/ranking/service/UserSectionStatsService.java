package com.groupone.backend.features.ranking.service;

import com.groupone.backend.features.appconfig.entity.AppScreenSection;
import com.groupone.backend.features.appconfig.repository.AppScreenSectionRepository;
import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.features.ranking.entity.UserSectionStats;
import com.groupone.backend.features.ranking.repository.UserSectionStatsRepository;
import com.groupone.backend.features.smarttest.repository.UserQuestionAttemptRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserSectionStatsService {

    private final UserSectionStatsRepository statsRepository;
    private final UserRepository userRepository;
    private final AppScreenSectionRepository sectionRepository;
    private final UserQuestionAttemptRepository userQuestionAttemptRepository;
    private final com.groupone.backend.features.quizbank.repository.QuestionRepository questionRepository;

    @Transactional
    public void recordSectionResult(Long userId, Long sectionId, com.groupone.backend.features.ranking.dto.RecordAnswersRequest request) {
        log.info("[UserSectionStatsService] recordSectionResult: user={}, section={}, requestCount={}, attemptsSize={}", 
                 userId, sectionId, request.getCount(), (request.getAttempts() != null ? request.getAttempts().size() : 0));
                 
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        UserSectionStats stats = statsRepository.findByUserIdAndSectionId(userId, sectionId)
                .orElseGet(() -> {
                    AppScreenSection section = sectionRepository.findById(sectionId)
                            .orElseThrow(() -> new RuntimeException("Section not found"));
                    return UserSectionStats.builder()
                            .user(user)
                            .section(section)
                            .totalCorrectAnswers(0)
                            .totalQuestionsAttempted(0)
                            .build();
                });

        int newCorrect = 0;
        int totalAttempted = 0;

        if (request.getAttempts() != null && !request.getAttempts().isEmpty()) {
            for (com.groupone.backend.features.ranking.dto.QuestionAttemptDTO attempt : request.getAttempts()) {
                totalAttempted++;
                
                com.groupone.backend.features.quizbank.entity.Question question = questionRepository.findById(attempt.getQuestionId())
                        .orElse(null);
                        
                if (question != null) {
                    boolean wasCorrectInSection = userQuestionAttemptRepository.existsByUserIdAndSectionIdAndQuestionIdAndIsCorrect(userId, sectionId, question.getId(), true);
                    log.debug("  Processing qid={}, isCorrect={}, wasCorrectInSection={}", question.getId(), attempt.isCorrect(), wasCorrectInSection);
                    
                    com.groupone.backend.features.smarttest.entity.UserQuestionAttempt uqa = com.groupone.backend.features.smarttest.entity.UserQuestionAttempt.builder()
                            .user(user)
                            .section(stats.getSection())
                            .question(question)
                            .userAnswer(attempt.getUserAnswer())
                            .isCorrect(attempt.isCorrect())
                            .build();
                    userQuestionAttemptRepository.save(uqa);
                    
                    if (attempt.isCorrect() && !wasCorrectInSection) {
                        newCorrect++;
                    }
                } else {
                    log.warn("  Question NOT FOUND: id={}", attempt.getQuestionId());
                }
            }
        } else {
            log.warn("  No attempts provided in request; using count={}", request.getCount());
            newCorrect = request.getCount();
            totalAttempted = request.getCount();
        }

        stats.setTotalCorrectAnswers(stats.getTotalCorrectAnswers() + newCorrect);
        stats.setTotalQuestionsAttempted(stats.getTotalQuestionsAttempted() + totalAttempted);
        
        log.info("  Final Stats: totalCorrect={}, attempted={}", stats.getTotalCorrectAnswers(), stats.getTotalQuestionsAttempted());
        statsRepository.save(stats);
    }

    public List<Long> getSolvedQuestionIds(Long userId) {
        return userQuestionAttemptRepository.findCorrectQuestionIdsByUser(userId);
    }

    public Optional<UserSectionStats> getStatsBySection(Long userId, Long sectionId) {
        return statsRepository.findByUserIdAndSectionId(userId, sectionId);
    }
}
