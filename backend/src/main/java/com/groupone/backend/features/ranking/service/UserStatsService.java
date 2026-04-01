package com.groupone.backend.features.ranking.service;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.features.ranking.dto.LeaderboardEntryDto;
import com.groupone.backend.features.ranking.dto.MyRankResponse;
import com.groupone.backend.features.ranking.entity.UserStats;
import com.groupone.backend.features.ranking.repository.UserStatsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.IntStream;

@Service
@RequiredArgsConstructor
public class UserStatsService {

    private final UserStatsRepository statsRepository;
    private final UserRepository userRepository;

    // ── Upsert helpers ───────────────────────────────────────────────────────

    @Transactional
    private UserStats getOrCreate(Long userId) {
        return statsRepository.findByUserId(userId).orElseGet(() -> {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found: " + userId));
            System.out.println("[UserStatsService] Creating new UserStats row for userId=" + userId);
            UserStats stats = UserStats.builder().user(user).build();
            return statsRepository.save(stats);
        });
    }

    // ── Recording methods ────────────────────────────────────────────────────

    @Transactional
    public void recordCorrectAnswers(Long userId, int count) {
        System.out.println("[UserStatsService] recordCorrectAnswers userId=" + userId + " count=" + count);
        UserStats stats = getOrCreate(userId);
        stats.setTotalCorrectAnswers(stats.getTotalCorrectAnswers() + count);
        statsRepository.save(stats);
    }

    @Transactional
    public void recordVocabCorrect(Long userId, int count) {
        System.out.println("[UserStatsService] recordVocabCorrect userId=" + userId + " count=" + count);
        UserStats stats = getOrCreate(userId);
        stats.setTotalVocabCorrect(stats.getTotalVocabCorrect() + count);
        statsRepository.save(stats);
    }

    @Transactional
    public void recordAppTime(Long userId, long seconds) {
        System.out.println("[UserStatsService] recordAppTime userId=" + userId + " seconds=" + seconds);
        UserStats stats = getOrCreate(userId);
        stats.setTotalTimeSeconds(stats.getTotalTimeSeconds() + seconds);
        statsRepository.save(stats);
    }

    // ── Leaderboard ──────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<LeaderboardEntryDto> getLeaderboard(String type, int page, int size) {
        System.out.println("[UserStatsService] getLeaderboard type=" + type + " page=" + page + " size=" + size);
        PageRequest pageable = PageRequest.of(page, size);

        List<UserStats> rows = switch (type.toUpperCase()) {
            case "VOCAB" -> statsRepository.findTopByVocabCorrect(pageable);
            case "TIME"  -> statsRepository.findTopByTimeSeconds(pageable);
            default      -> statsRepository.findTopByCorrectAnswers(pageable);
        };

        int offset = page * size;
        return IntStream.range(0, rows.size())
                .mapToObj(i -> mapToEntry(rows.get(i), offset + i + 1, type))
                .toList();
    }

    @Transactional(readOnly = true)
    public MyRankResponse getMyRank(Long userId, String type) {
        System.out.println("[UserStatsService] getMyRank userId=" + userId + " type=" + type);
        UserStats stats = statsRepository.findByUserId(userId).orElse(null);

        if (stats == null) {
            return MyRankResponse.builder()
                    .userId(userId).myRank(0).myScore(0).ranked(false).build();
        }

        long score = switch (type.toUpperCase()) {
            case "VOCAB" -> stats.getTotalVocabCorrect();
            case "TIME"  -> stats.getTotalTimeSeconds();
            default      -> stats.getTotalCorrectAnswers();
        };

        if (score == 0) {
            return MyRankResponse.builder()
                    .userId(userId).myRank(0).myScore(0).ranked(false).build();
        }

        long rank = switch (type.toUpperCase()) {
            case "VOCAB" -> statsRepository.findRankByVocab(userId);
            case "TIME"  -> statsRepository.findRankByTime(userId);
            default      -> statsRepository.findRankByAnswers(userId);
        };

        return MyRankResponse.builder()
                .userId(userId).myRank(rank).myScore(score).ranked(true).build();
    }

    // ── Mapper ───────────────────────────────────────────────────────────────

    private LeaderboardEntryDto mapToEntry(UserStats stats, int rank, String type) {
        User user = stats.getUser();
        String displayName = user.getProfile() != null && user.getProfile().getFullName() != null
                ? user.getProfile().getFullName()
                : user.getEmail().split("@")[0];
        String avatarUrl = user.getProfile() != null ? user.getProfile().getAvatarUrl() : null;

        long score = switch (type.toUpperCase()) {
            case "VOCAB" -> stats.getTotalVocabCorrect();
            case "TIME"  -> stats.getTotalTimeSeconds();
            default      -> stats.getTotalCorrectAnswers();
        };

        return LeaderboardEntryDto.builder()
                .rank(rank)
                .userId(user.getId())
                .displayName(displayName)
                .avatarUrl(avatarUrl)
                .isPro(Boolean.TRUE.equals(user.getIsPro()))
                .score(score)
                .build();
    }
}
