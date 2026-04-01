package com.groupone.backend.features.moderation.repository;

import com.groupone.backend.features.moderation.entity.Report;
import com.groupone.backend.features.moderation.enums.ReportedItemType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ReportRepository extends JpaRepository<Report, Long> {
    
    long countByReporterIdAndCreatedAtAfter(Long reporterId, LocalDateTime after);
    
    Optional<Report> findByReporterIdAndItemTypeAndItemIdAndStatus(
            Long reporterId, 
            ReportedItemType itemType, 
            Long itemId, 
            com.groupone.backend.features.moderation.enums.ReportStatus status
    );

    List<Report> findByStatusOrderByCreatedAtDesc(com.groupone.backend.features.moderation.enums.ReportStatus status);
}
