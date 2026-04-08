package com.groupone.backend.features.feedback.dto;

import com.groupone.backend.features.feedback.FeedbackStatus;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class FeedbackDto {
    private Long id;
    private Long userId;
    private String userEmail;
    private String userFullName;
    private String title;
    private String textContent;
    private String imageUrl;
    private FeedbackStatus status;
    private LocalDateTime createdAt;
}
