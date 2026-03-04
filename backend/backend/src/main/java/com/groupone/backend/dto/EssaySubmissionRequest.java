package com.groupone.backend.dto;

import com.groupone.backend.model.EssaySubmission.GradingType;
import lombok.Data;

@Data
public class EssaySubmissionRequest {
    private Long topicId;
    private String content;
    private GradingType gradingType;
}
