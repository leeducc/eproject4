package com.groupone.backend.features.notification.controller;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.features.notification.entity.SystemNotification;
import com.groupone.backend.features.notification.service.SystemNotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/system-notifications")
@RequiredArgsConstructor
public class SystemNotificationController {

    private final SystemNotificationService systemNotificationService;
    private final UserRepository userRepository;

    private User getCurrentUser() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof User) {
            return (User) principal;
        }
        
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("User not found: " + email));
    }

    @PostMapping("/admin")
    public ResponseEntity<SystemNotification> createNotification(@RequestBody Map<String, String> request) {
        User admin = getCurrentUser();
        SystemNotification notification = systemNotificationService.createNotification(
                request.get("title"),
                request.get("content"),
                request.getOrDefault("type", "GENERAL"),
                admin.getId()
        );
        return ResponseEntity.ok(notification);
    }

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getNotifications() {
        User user = getCurrentUser();
        return ResponseEntity.ok(systemNotificationService.getNotificationsForUser(user.getId()));
    }

    @PostMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(@PathVariable Long id) {
        User user = getCurrentUser();
        systemNotificationService.markAsRead(user.getId(), id);
        return ResponseEntity.ok().build();
    }
}
