package com.groupone.backend.features.ranking.repository;

import com.groupone.backend.features.ranking.entity.UserSectionStats;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserSectionStatsRepository extends JpaRepository<UserSectionStats, Long> {
    Optional<UserSectionStats> findByUserIdAndSectionId(Long userId, Long sectionId);
    List<UserSectionStats> findByUserId(Long userId);
}
