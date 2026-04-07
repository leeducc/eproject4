package com.groupone.backend.features.notification.repository;

import com.groupone.backend.features.notification.entity.UserNotification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.List;

@Repository
public interface UserNotificationRepository extends JpaRepository<UserNotification, Long> {
    Optional<UserNotification> findByUserIdAndNotificationId(Long userId, Long notificationId);
    List<UserNotification> findAllByUserId(Long userId);
}
