package com.groupone.backend.features.quizbank.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.groupone.backend.features.quizbank.enums.DifficultyBand;
import com.groupone.backend.features.quizbank.enums.QuestionType;
import com.groupone.backend.features.quizbank.enums.SkillType;
import lombok.Builder;
import lombok.Data;
import java.util.Map;
import java.util.List;

@Data
@Builder
public class QuestionResponse {
    private Long id;
    
    private SkillType skill;

    private QuestionType type;

    private DifficultyBand difficultyBand;

    private Map<String, Object> data;

    private Boolean isPremiumContent;

    private String instruction;
    
    private String explanation;

    private List<String> mediaUrls;
    
    private List<String> mediaTypes;
}
