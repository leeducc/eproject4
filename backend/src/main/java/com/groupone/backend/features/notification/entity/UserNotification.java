package com.groupone.backend.features.notification.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_notifications", 
       uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "notification_id"}))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserNotification {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "notification_id", nullable = false)
    private Long notificationId;

    @Column(nullable = false)
    private LocalDateTime readAt;

    @Builder.Default
    private boolean isRead = true; 
}
