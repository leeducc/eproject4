package com.groupone.backend.features.chat;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    
    @Query("SELECT m FROM ChatMessage m WHERE " +
           "(m.sender.id = :userId1 AND m.receiver.id = :userId2) OR " +
           "(m.sender.id = :userId2 AND m.receiver.id = :userId1) " +
           "ORDER BY m.createdAt ASC")
    List<ChatMessage> findConversation(@Param("userId1") Long userId1, @Param("userId2") Long userId2);

    @Query("SELECT m.sender.id, COUNT(m) FROM ChatMessage m WHERE m.receiver.id = :receiverId AND m.isRead = false GROUP BY m.sender.id")
    List<Object[]> countUnreadByReceiverGroupedBySender(@Param("receiverId") Long receiverId);

    @Query("SELECT m FROM ChatMessage m WHERE m.id IN (SELECT MAX(m2.id) FROM ChatMessage m2 WHERE m2.receiver.id = :receiverId AND m2.isRead = false GROUP BY m2.sender.id)")
    List<ChatMessage> findLatestUnreadMessagesPerSender(@Param("receiverId") Long receiverId);

    @Modifying
    @Transactional
    @Query("UPDATE ChatMessage m SET m.isRead = true WHERE m.receiver.id = :receiverId AND m.sender.id = :senderId AND m.isRead = false")
    void markAsRead(@Param("receiverId") Long receiverId, @Param("senderId") Long senderId);
}
