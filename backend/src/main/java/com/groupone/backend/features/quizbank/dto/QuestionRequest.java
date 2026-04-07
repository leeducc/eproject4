package com.groupone.backend.features.quizbank.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.groupone.backend.features.quizbank.enums.DifficultyBand;
import com.groupone.backend.features.quizbank.enums.QuestionType;
import com.groupone.backend.features.quizbank.enums.SkillType;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.util.Map;
import java.util.List;

@Data
public class QuestionRequest {
    @NotNull
    private SkillType skill;

    @NotNull
    private QuestionType type;

    @NotNull
    private DifficultyBand difficultyBand;

    
    private String instruction;
    
    
    private String explanation;

    private Map<String, Object> data;

    @NotNull
    @JsonProperty("isPremiumContent")
    private Boolean isPremiumContent;

    private List<String> mediaUrls;
    
    private List<String> mediaTypes;

    private List<String> retainedMediaUrls;

    private Long groupId;

    private Long authorId;

    private List<String> tags; 
}
