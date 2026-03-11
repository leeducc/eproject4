package com.groupone.backend.features.writing;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WritingTopicRepository extends JpaRepository<WritingTopic, Long> {
}
