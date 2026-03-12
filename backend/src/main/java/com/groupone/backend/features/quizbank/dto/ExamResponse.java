package com.groupone.backend.features.quizbank.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.groupone.backend.features.quizbank.enums.ExamType;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class ExamResponse {
    private Long id;
    private String title;
    private String description;

    @JsonProperty("exam_type")
    private ExamType examType;
    
    @JsonProperty("created_at")
    private LocalDateTime createdAt;

    private List<QuestionResponse> questions;
}
