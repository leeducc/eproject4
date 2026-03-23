package com.groupone.backend.features.writing.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GradingRequest {
    private Double taskAchievement;
    private Double cohesionCoherence;
    private Double lexicalResource;
    private Double grammaticalRange;
    private String teacherFeedback;

    private String taskAchievementReason;
    private String cohesionCoherenceReason;
    private String lexicalResourceReason;
    private String grammaticalRangeReason;
    private String correctionsJson;
}
