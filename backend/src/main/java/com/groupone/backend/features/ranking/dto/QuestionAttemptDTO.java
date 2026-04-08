package com.groupone.backend.features.ranking.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class QuestionAttemptDTO {
    private Long questionId;
    private String userAnswer;
    private boolean isCorrect;
}
