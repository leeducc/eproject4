package com.groupone.backend.features.smarttest.dto;

import lombok.Data;
import java.util.List;

@Data
public class SmartTestSubmitRequest {
    private String skill;
    private String difficultyBand;
    private List<QuestionAttemptDTO> attempts;
}
