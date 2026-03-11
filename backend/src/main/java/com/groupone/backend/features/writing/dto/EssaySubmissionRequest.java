package com.groupone.backend.features.writing.dto;

import com.groupone.backend.features.writing.GradingType;
import lombok.Data;

@Data
public class EssaySubmissionRequest {
    private Long topicId;
    private String content;
    private GradingType gradingType; // "HUMAN" or "AI"
}
