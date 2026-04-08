package com.groupone.backend.features.feedback.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class FeedbackMessageDto {
    private Long id;
    private Long senderId;
    @com.fasterxml.jackson.annotation.JsonProperty("isAdmin")
    private boolean isAdmin;
    private String textContent;
    private LocalDateTime createdAt;
}
