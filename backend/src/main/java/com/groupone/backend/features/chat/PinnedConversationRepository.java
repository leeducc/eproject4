package com.groupone.backend.features.chat;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PinnedConversationRepository extends JpaRepository<PinnedConversation, Long> {
    List<PinnedConversation> findByUserId(Long userId);
    Optional<PinnedConversation> findByUserIdAndPinnedUserId(Long userId, Long pinnedUserId);
    boolean existsByUserIdAndPinnedUserId(Long userId, Long pinnedUserId);
    void deleteByUserIdAndPinnedUserId(Long userId, Long pinnedUserId);
}
