package com.groupone.backend.features.appconfig.repository;

import com.groupone.backend.features.appconfig.entity.PolicyHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PolicyHistoryRepository extends JpaRepository<PolicyHistory, Long> {
    List<PolicyHistory> findAllByTypeOrderByChangedAtDesc(String type);
}
