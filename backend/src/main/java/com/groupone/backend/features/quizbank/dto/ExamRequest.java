package com.groupone.backend.features.quizbank.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.groupone.backend.features.quizbank.enums.ExamType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.util.List;

@Data
public class ExamRequest {
    @NotBlank
    private String title;

    private String description;

    @NotNull
    @JsonProperty("exam_type")
    private ExamType examType;

    @JsonProperty("question_ids")
    private List<Long> questionIds;
}
