package com.groupone.backend.repository;

import com.groupone.backend.model.EssaySubmission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EssaySubmissionRepository extends JpaRepository<EssaySubmission, Long> {
    List<EssaySubmission> findByTopicId(Long topicId);
}
