package com.groupone.backend.features.ranking.service;

import com.groupone.backend.features.appconfig.entity.AppScreenSection;
import com.groupone.backend.features.appconfig.repository.AppScreenSectionRepository;
import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.features.ranking.entity.UserSectionStats;
import com.groupone.backend.features.ranking.repository.UserSectionStatsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserSectionStatsService {

    private final UserSectionStatsRepository statsRepository;
    private final UserRepository userRepository;
    private final AppScreenSectionRepository sectionRepository;

    @Transactional
    public void recordSectionResult(Long userId, Long sectionId, int correctCount, int totalCount) {
        UserSectionStats stats = statsRepository.findByUserIdAndSectionId(userId, sectionId)
                .orElseGet(() -> {
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new RuntimeException("User not found"));
                    AppScreenSection section = sectionRepository.findById(sectionId)
                            .orElseThrow(() -> new RuntimeException("Section not found"));
                    return UserSectionStats.builder()
                            .user(user)
                            .section(section)
                            .totalCorrectAnswers(0)
                            .totalQuestionsAttempted(0)
                            .build();
                });

        stats.setTotalCorrectAnswers(stats.getTotalCorrectAnswers() + correctCount);
        stats.setTotalQuestionsAttempted(stats.getTotalQuestionsAttempted() + totalCount);

        statsRepository.save(stats);
    }

    public Optional<UserSectionStats> getStatsBySection(Long userId, Long sectionId) {
        return statsRepository.findByUserIdAndSectionId(userId, sectionId);
    }
}
