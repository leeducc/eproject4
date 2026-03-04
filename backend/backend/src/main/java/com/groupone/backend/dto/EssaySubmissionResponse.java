package com.groupone.backend.dto;

import com.groupone.backend.model.EssaySubmission.GradingType;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class EssaySubmissionResponse {
    private Long id;
    private TopicDto topic;
    private String content;
    private GradingType gradingType;
    private String aiFeedback;
    private Double score;
    private LocalDateTime createdAt;
}
