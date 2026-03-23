package com.groupone.backend.features.quizbank.dto;

import com.groupone.backend.features.quizbank.enums.DifficultyBand;
import com.groupone.backend.features.quizbank.enums.SkillType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class QuestionGroupRequest {
    @NotNull
    private SkillType skill;

    @NotBlank
    private String title;

    private String content;

    private String mediaUrl;

    private String mediaType;

    @NotNull
    private DifficultyBand difficultyBand;

    private Long authorId;

    private List<QuestionRequest> questions;
}
