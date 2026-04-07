package com.groupone.backend.features.chat.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UnreadNotificationDto {
    private Long senderId;
    private String senderName;
    private long count;
    private String lastMessage;
}
