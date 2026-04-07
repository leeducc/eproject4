package com.groupone.backend.features.chat.dto;

import com.groupone.backend.shared.enums.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserChatStatusDto {
    private Long id;
    private String fullName;
    private String email;
    private UserRole role;
    private boolean isOnline;
    private boolean isPinned;
    private long unreadCount;
    private String lastMessage;
    private String lastMessageAt;
}
