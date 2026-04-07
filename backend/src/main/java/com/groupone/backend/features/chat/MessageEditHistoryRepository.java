package com.groupone.backend.features.chat;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageEditHistoryRepository extends JpaRepository<MessageEditHistory, Long> {
    List<MessageEditHistory> findByMessageIdOrderByEditedAtDesc(Long messageId);
}
