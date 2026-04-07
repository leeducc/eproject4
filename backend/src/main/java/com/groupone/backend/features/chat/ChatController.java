package com.groupone.backend.features.chat;

import com.groupone.backend.features.chat.dto.ChatMessageDto;
import com.groupone.backend.features.chat.dto.UnreadNotificationDto;
import com.groupone.backend.features.chat.dto.UserChatStatusDto;
import com.groupone.backend.features.media.MediaFile;
import com.groupone.backend.features.media.MediaService;
import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.shared.enums.UserRole;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;
    private final MediaService mediaService;
    private final UserRepository userRepository;

    @GetMapping("/{otherUserId}")
    public ResponseEntity<List<ChatMessageDto>> getConversation(@PathVariable Long otherUserId) {
        Long currentUserId = getCurrentUserId();
        return ResponseEntity.ok(chatService.getConversation(currentUserId, otherUserId));
    }

    @PostMapping("/send")
    public ResponseEntity<ChatMessageDto> sendMessage(
            @RequestParam("receiverId") Long receiverId,
            @RequestParam(value = "content", required = false) String content,
            @RequestParam(value = "file", required = false) MultipartFile file) throws IOException {
        
        Long currentUserId = getCurrentUserId();
        String mediaUrl = null;
        String mediaType = null;

        if (file != null && !file.isEmpty()) {
            MediaFile uploaded = mediaService.uploadFile(file, currentUserId, "chat");
            mediaUrl = uploaded.getStoredPath();
            mediaType = file.getContentType() != null && file.getContentType().equalsIgnoreCase("application/pdf") ? "PDF" : "IMAGE";
        }

        return ResponseEntity.ok(chatService.sendMessage(currentUserId, receiverId, content, mediaUrl, mediaType));
    }

    @PutMapping("/message/{messageId}")
    public ResponseEntity<ChatMessageDto> editMessage(@PathVariable Long messageId, @RequestBody String content) {
        Long currentUserId = getCurrentUserId();
        return ResponseEntity.ok(chatService.editMessage(currentUserId, messageId, content));
    }

    @GetMapping("/message/{messageId}/history")
    public ResponseEntity<List<MessageEditHistory>> getEditHistory(@PathVariable Long messageId) {
        return ResponseEntity.ok(chatService.getEditHistory(messageId));
    }

    @GetMapping("/admin-id")
    public ResponseEntity<Long> getAdminId() {
        return ResponseEntity.ok(chatService.getAdminId());
    }

    @GetMapping("/admins")
    public ResponseEntity<List<UserChatStatusDto>> getAdmins() {
        return ResponseEntity.ok(chatService.getChatUserList(getCurrentUserId(), UserRole.ADMIN));
    }

    @GetMapping("/teachers")
    public ResponseEntity<List<UserChatStatusDto>> getTeachers() {
        return ResponseEntity.ok(chatService.getChatUserList(getCurrentUserId(), UserRole.TEACHER));
    }

    @PostMapping("/{targetUserId}/pin")
    public ResponseEntity<Void> togglePin(@PathVariable Long targetUserId) {
        chatService.togglePin(getCurrentUserId(), targetUserId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/unread-counts")
    public ResponseEntity<Map<Long, Long>> getUnreadCounts() {
        return ResponseEntity.ok(chatService.getUnreadCounts(getCurrentUserId()));
    }

    @GetMapping("/unread-notifications")
    public ResponseEntity<List<UnreadNotificationDto>> getUnreadNotifications() {
        return ResponseEntity.ok(chatService.getUnreadNotifications(getCurrentUserId()));
    }

    @PostMapping("/mark-read/{senderId}")
    public ResponseEntity<Void> markAsRead(@PathVariable Long senderId) {
        chatService.markAsRead(getCurrentUserId(), senderId);
        return ResponseEntity.ok().build();
    }

    private Long getCurrentUserId() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof User) {
            return ((User) principal).getId();
        }
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .map(User::getId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
    }
}
