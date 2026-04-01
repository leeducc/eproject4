package com.groupone.backend.features.ranking.controller;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.ranking.dto.LeaderboardEntryDto;
import com.groupone.backend.features.ranking.dto.MyRankResponse;
import com.groupone.backend.features.ranking.dto.RecordAnswersRequest;
import com.groupone.backend.features.ranking.dto.RecordTimeRequest;
import com.groupone.backend.features.ranking.service.UserStatsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/v1/ranking")
@RequiredArgsConstructor
public class RankingController {

    private final UserStatsService statsService;

    // ── Public endpoints (leaderboard visible without login) ─────────────────

    @GetMapping("/leaderboard")
    public ResponseEntity<List<LeaderboardEntryDto>> getLeaderboard(
            @RequestParam(defaultValue = "ANSWERS") String type,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        log.info("[RankingController] GET leaderboard type={} page={} size={}", type, page, size);
        return ResponseEntity.ok(statsService.getLeaderboard(type, page, size));
    }

    // ── Authenticated endpoints ───────────────────────────────────────────────

    @GetMapping("/my-rank")
    public ResponseEntity<MyRankResponse> getMyRank(
            @RequestParam(defaultValue = "ANSWERS") String type) {
        Long userId = getCurrentUserId();
        log.info("[RankingController] GET my-rank userId={} type={}", userId, type);
        return ResponseEntity.ok(statsService.getMyRank(userId, type));
    }

    @PostMapping("/record-answers")
    public ResponseEntity<Void> recordAnswers(@RequestBody RecordAnswersRequest request) {
        Long userId = getCurrentUserId();
        log.info("[RankingController] POST record-answers userId={} count={}", userId, request.getCount());
        statsService.recordCorrectAnswers(userId, request.getCount());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/record-vocab")
    public ResponseEntity<Void> recordVocab(@RequestBody RecordAnswersRequest request) {
        Long userId = getCurrentUserId();
        log.info("[RankingController] POST record-vocab userId={} count={}", userId, request.getCount());
        statsService.recordVocabCorrect(userId, request.getCount());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/record-time")
    public ResponseEntity<Void> recordTime(@RequestBody RecordTimeRequest request) {
        Long userId = getCurrentUserId();
        log.info("[RankingController] POST record-time userId={} seconds={}", userId, request.getSeconds());
        statsService.recordAppTime(userId, request.getSeconds());
        return ResponseEntity.ok().build();
    }

    // ── Helper ───────────────────────────────────────────────────────────────

    private Long getCurrentUserId() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof User user) {
            return user.getId();
        }
        throw new RuntimeException("User not authenticated");
    }
}
