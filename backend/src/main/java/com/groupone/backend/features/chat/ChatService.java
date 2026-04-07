package com.groupone.backend.features.chat;

import com.groupone.backend.features.chat.dto.ChatMessageDto;
import com.groupone.backend.features.chat.dto.UnreadNotificationDto;
import com.groupone.backend.features.chat.dto.UserChatStatusDto;
import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.shared.enums.UserRole;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChatService {

    private final ChatMessageRepository chatMessageRepository;
    private final MessageEditHistoryRepository editHistoryRepository;
    private final UserRepository userRepository;
    private final PinnedConversationRepository pinnedRepo;
    private final SimpMessagingTemplate messagingTemplate;

    public List<ChatMessageDto> getConversation(Long currentUserId, Long otherUserId) {
        return chatMessageRepository.findConversation(currentUserId, otherUserId)
                .stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public ChatMessageDto sendMessage(Long senderId, Long receiverId, String content, String mediaUrl, String mediaType) {
        if (senderId.equals(receiverId)) {
            throw new IllegalArgumentException("Cannot send message to yourself");
        }

        User sender = userRepository.findById(senderId)
                .orElseThrow(() -> new IllegalArgumentException("Sender not found"));
        User receiver = userRepository.findById(receiverId)
                .orElseThrow(() -> new IllegalArgumentException("Receiver not found"));

        ChatMessage message = ChatMessage.builder()
                .sender(sender)
                .receiver(receiver)
                .content(content)
                .mediaUrl(mediaUrl)
                .mediaType(mediaType)
                .isRead(false)
                .build();

        ChatMessage savedMessage = chatMessageRepository.save(message);
        ChatMessageDto dto = convertToDto(savedMessage);

        log.info("[ChatService] Sending message from {} to {}: {}", senderId, receiverId, content);

        
        messagingTemplate.convertAndSend("/topic/chat/" + senderId, dto);
        messagingTemplate.convertAndSend("/topic/chat/" + receiverId, dto);

        return dto;
    }

    public List<UserChatStatusDto> getChatUserList(Long userId, UserRole targetRole) {
        List<User> targets = userRepository.findByRoleAndSearch(targetRole, null);
        List<PinnedConversation> pinned = pinnedRepo.findByUserId(userId);
        Map<Long, Long> unreadCounts = getUnreadCounts(userId);
        
        return targets.stream().map(target -> {
            boolean isPinned = pinned.stream()
                .anyMatch(p -> p.getPinnedUser().getId().equals(target.getId()));
            
            return UserChatStatusDto.builder()
                .id(target.getId())
                .fullName(target.getProfile() != null ? target.getProfile().getFullName() : "System User")
                .email(target.getEmail())
                .role(target.getRole())
                .isOnline(target.isOnline())
                .isPinned(isPinned)
                .unreadCount(unreadCounts.getOrDefault(target.getId(), 0L))
                .build();
        }).collect(Collectors.toList());
    }

    @Transactional
    public void togglePin(Long userId, Long targetUserId) {
        Optional<PinnedConversation> existing = pinnedRepo.findByUserIdAndPinnedUserId(userId, targetUserId);
        if (existing.isPresent()) {
            pinnedRepo.delete(existing.get());
        } else {
            User user = userRepository.findById(userId).orElseThrow();
            User target = userRepository.findById(targetUserId).orElseThrow();
            PinnedConversation pin = PinnedConversation.builder()
                .user(user)
                .pinnedUser(target)
                .build();
            pinnedRepo.save(pin);
        }
    }

    public Map<Long, Long> getUnreadCounts(Long userId) {
        List<Object[]> results = chatMessageRepository.countUnreadByReceiverGroupedBySender(userId);
        Map<Long, Long> unreadCounts = new HashMap<>();
        for (Object[] result : results) {
            unreadCounts.put((Long) result[0], (Long) result[1]);
        }
        return unreadCounts;
    }

    public List<UnreadNotificationDto> getUnreadNotifications(Long userId) {
        Map<Long, Long> counts = getUnreadCounts(userId);
        List<ChatMessage> latestMessages = chatMessageRepository.findLatestUnreadMessagesPerSender(userId);

        return latestMessages.stream().map(msg -> {
            Long senderId = msg.getSender().getId();
            String senderName = msg.getSender().getProfile() != null
                ? msg.getSender().getProfile().getFullName()
                : "Staff member";

            return UnreadNotificationDto.builder()
                .senderId(senderId)
                .senderName(senderName)
                .count(counts.getOrDefault(senderId, 0L))
                .lastMessage(msg.getContent() != null ? msg.getContent() : (msg.getMediaType() != null ? "[" + msg.getMediaType() + "]" : "[Message]"))
                .build();
        }).collect(Collectors.toList());
    }

    @Transactional
    public void markAsRead(Long currentUserId, Long senderId) {
        chatMessageRepository.markAsRead(currentUserId, senderId);
    }

    public Long getAdminId() {
        return userRepository.findByRoleAndSearch(UserRole.ADMIN, null)
                .stream()
                .findFirst()
                .map(User::getId)
                .orElseThrow(() -> new IllegalArgumentException("No admin user found in the system"));
    }

    @Transactional
    public ChatMessageDto editMessage(Long userId, Long messageId, String newContent) {
        ChatMessage message = chatMessageRepository.findById(messageId)
                .orElseThrow(() -> new IllegalArgumentException("Message not found"));

        if (!message.getSender().getId().equals(userId)) {
            throw new IllegalArgumentException("Only the sender can edit their message");
        }

        
        MessageEditHistory history = MessageEditHistory.builder()
                .message(message)
                .oldContent(message.getContent())
                .editedAt(LocalDateTime.now())
                .build();
        editHistoryRepository.save(history);

        
        message.setContent(newContent);
        message.setEdited(true);
        ChatMessage savedMessage = chatMessageRepository.save(message);
        ChatMessageDto dto = convertToDto(savedMessage);

        
        messagingTemplate.convertAndSend("/topic/chat/" + message.getSender().getId(), dto);
        messagingTemplate.convertAndSend("/topic/chat/" + message.getReceiver().getId(), dto);

        return dto;
    }

    public List<MessageEditHistory> getEditHistory(Long messageId) {
        return editHistoryRepository.findByMessageIdOrderByEditedAtDesc(messageId);
    }

    private ChatMessageDto convertToDto(ChatMessage message) {
        return ChatMessageDto.builder()
                .id(message.getId())
                .senderId(message.getSender().getId())
                .receiverId(message.getReceiver().getId())
                .content(message.getContent())
                .mediaUrl(message.getMediaUrl())
                .mediaType(message.getMediaType())
                .isEdited(message.isEdited())
                .createdAt(message.getCreatedAt())
                .updatedAt(message.getUpdatedAt())
                .build();
    }
}
