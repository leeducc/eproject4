package com.groupone.backend.features.notification.service;

import com.groupone.backend.features.notification.entity.SystemNotification;
import com.groupone.backend.features.notification.entity.UserNotification;
import com.groupone.backend.features.notification.repository.SystemNotificationRepository;
import com.groupone.backend.features.notification.repository.UserNotificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class SystemNotificationService {
    private final SystemNotificationRepository systemNotificationRepository;
    private final UserNotificationRepository userNotificationRepository;

    public SystemNotification createNotification(String title, String content, String type, Long adminId) {
        log.info("[SystemNotificationService] Creating new global notification: {}", title);
        SystemNotification notification = SystemNotification.builder()
                .title(title)
                .content(content)
                .type(type)
                .adminId(adminId)
                .build();
        return systemNotificationRepository.save(notification);
    }

    public List<Map<String, Object>> getNotificationsForUser(Long userId) {
        List<SystemNotification> allNotifications = systemNotificationRepository.findAllByOrderByCreatedAtDesc();
        List<UserNotification> readStatus = userNotificationRepository.findAllByUserId(userId);
        
        Map<Long, LocalDateTime> readMap = readStatus.stream()
                .collect(Collectors.toMap(UserNotification::getNotificationId, UserNotification::getReadAt));

        return allNotifications.stream().map(n -> {
            boolean isRead = readMap.containsKey(n.getId());
            Map<String, Object> map = new java.util.HashMap<>();
            map.put("id", n.getId());
            map.put("title", n.getTitle());
            map.put("content", n.getContent());
            map.put("type", n.getType());
            map.put("createdAt", n.getCreatedAt());
            map.put("isRead", isRead);
            return map;
        }).collect(Collectors.toList());
    }

    @Transactional
    public void markAsRead(Long userId, Long notificationId) {
        if (userNotificationRepository.findByUserIdAndNotificationId(userId, notificationId).isEmpty()) {
            UserNotification userNotification = UserNotification.builder()
                    .userId(userId)
                    .notificationId(notificationId)
                    .readAt(LocalDateTime.now())
                    .build();
            userNotificationRepository.save(userNotification);
        }
    }
}
