package com.groupone.backend.features.ranking.controller;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.ranking.dto.RecordAnswersRequest;
import com.groupone.backend.features.ranking.service.UserSectionStatsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/section-stats")
@RequiredArgsConstructor
public class UserSectionStatsController {

    private final UserSectionStatsService statsService;

    @PostMapping("/{sectionId}/record")
    public ResponseEntity<Void> recordResult(
            @PathVariable Long sectionId,
            @RequestBody RecordAnswersRequest request) { 
        Long userId = getCurrentUserId();
        
        
        statsService.recordSectionResult(userId, sectionId, request.getCount(), request.getCount()); 
        return ResponseEntity.ok().build();
    }

    private Long getCurrentUserId() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof User user) {
            return user.getId();
        }
        throw new RuntimeException("User not authenticated");
    }
}
