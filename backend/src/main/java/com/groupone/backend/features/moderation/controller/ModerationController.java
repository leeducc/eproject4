package com.groupone.backend.features.moderation.controller;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.features.moderation.dto.ReportRequest;
import com.groupone.backend.features.moderation.dto.ResolveRequest;
import com.groupone.backend.features.moderation.entity.Report;
import com.groupone.backend.features.moderation.entity.ReportNotification;
import com.groupone.backend.features.moderation.enums.ReportStatus;
import com.groupone.backend.features.moderation.service.ModerationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/moderation")
@RequiredArgsConstructor
public class ModerationController {
    private final ModerationService moderationService;
    private final UserRepository userRepository;

    private User getCurrentUser() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof User) {
            return (User) principal;
        }

        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("User not found: " + email));
    }

    @PostMapping("/report")
    public ResponseEntity<Report> submitReport(@RequestBody ReportRequest request) {
        User user = getCurrentUser();
        Report report = moderationService.submitReport(
                user, 
                request.getItemType(), 
                request.getItemId(), 
                request.getReason()
        );
        return ResponseEntity.ok(report);
    }

    @GetMapping("/admin/reports")
    public ResponseEntity<List<Report>> getReports(@RequestParam ReportStatus status) {
        return ResponseEntity.ok(moderationService.getReports(status));
    }

    @PostMapping("/admin/resolve/{id}")
    public ResponseEntity<Report> resolveReport(
            @PathVariable Long id, 
            @RequestBody ResolveRequest request) {
        return ResponseEntity.ok(moderationService.resolveReport(
                id, 
                request.getAdminResponse(), 
                request.isDisableContent()
        ));
    }

    @PostMapping("/admin/dismiss/{id}")
    public ResponseEntity<Void> dismissSpam(@PathVariable Long id) {
        moderationService.dismissSpam(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/notifications")
    public ResponseEntity<List<ReportNotification>> getNotifications() {
        User user = getCurrentUser();
        return ResponseEntity.ok(moderationService.getNotifications(user.getId()));
    }

    @PostMapping("/notifications/{id}/read")
    public ResponseEntity<Void> markRead(@PathVariable Long id) {
        moderationService.markNotificationRead(id);
        return ResponseEntity.ok().build();
    }
}
