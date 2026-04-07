package com.groupone.backend.features.notification.repository;

import com.groupone.backend.features.notification.entity.SystemNotification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface SystemNotificationRepository extends JpaRepository<SystemNotification, Long> {
    List<SystemNotification> findAllByOrderByCreatedAtDesc();
}
