package com.groupone.backend.features.smarttest.dto;

import lombok.Data;

@Data
public class QuestionAttemptDTO {
    private Long questionId;
    private String userAnswer;
    private Boolean isCorrect;
}
