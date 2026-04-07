package com.groupone.backend.features.chat.dto;

import com.groupone.backend.core.validation.SafeHtml;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessageDto {
    private Long id;

    private Long senderId;

    private Long receiverId;

    @NotBlank(message = "Message content cannot be blank")
    @Size(max = 2000, message = "Message content is too long (max 2000 characters)")
    @SafeHtml(message = "HTML/Scripts are not allowed in messages")
    private String content;

    @Size(max = 512, message = "Media URL is too long")
    private String mediaUrl;

    private String mediaType;
    
    private boolean isEdited;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
