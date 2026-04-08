package com.groupone.backend.features.ranking.dto;

import lombok.Data;

import java.util.List;

@Data
public class RecordAnswersRequest {
    private int count;
    private List<QuestionAttemptDTO> attempts;
}
