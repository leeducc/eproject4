package com.groupone.backend.features.smarttest.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class SmartTestSubmitResponse {
    private Long sessionId;
    private Double score;
    private int correctCount;
    private int totalCount;
}
