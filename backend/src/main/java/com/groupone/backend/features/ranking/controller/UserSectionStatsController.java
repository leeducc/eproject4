package com.groupone.backend.features.ranking.controller;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.ranking.dto.RecordAnswersRequest;
import com.groupone.backend.features.ranking.service.UserSectionStatsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/api/v1/section-stats")
@RequiredArgsConstructor
public class UserSectionStatsController {

    private final UserSectionStatsService statsService;

    @PostMapping("/{sectionId}/record")
    public ResponseEntity<Void> recordResult(
            @PathVariable Long sectionId,
            @RequestBody RecordAnswersRequest request) { 
        log.info("[UserSectionStatsController] Received record request for section {}: {}", sectionId, request);
        Long userId = getCurrentUserId();
        statsService.recordSectionResult(userId, sectionId, request); 
        return ResponseEntity.ok().build();
    }

    @GetMapping("/solved-questions")
    public ResponseEntity<java.util.List<Long>> getSolvedQuestions() {
        Long userId = getCurrentUserId();
        return ResponseEntity.ok(statsService.getSolvedQuestionIds(userId));
    }

    private Long getCurrentUserId() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof User user) {
            return user.getId();
        }
        throw new RuntimeException("User not authenticated");
    }
}
