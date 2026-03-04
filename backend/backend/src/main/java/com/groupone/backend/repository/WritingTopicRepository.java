package com.groupone.backend.repository;

import com.groupone.backend.model.WritingTopic;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WritingTopicRepository extends JpaRepository<WritingTopic, Long> {
}
