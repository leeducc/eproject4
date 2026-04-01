package com.groupone.backend.features.moderation.repository;

import com.groupone.backend.features.moderation.entity.ReportNotification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReportNotificationRepository extends JpaRepository<ReportNotification, Long> {
    List<ReportNotification> findByUserIdAndIsReadFalseOrderByCreatedAtDesc(Long userId);
}
