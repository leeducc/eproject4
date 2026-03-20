package com.groupone.backend.features.quizbank.dto;

import com.groupone.backend.features.quizbank.enums.DifficultyBand;
import com.groupone.backend.features.quizbank.enums.SkillType;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class QuestionGroupResponse {
    private Long id;
    private SkillType skill;
    private String title;
    private String content;
    private String mediaUrl;
    private String mediaType;
    private DifficultyBand difficultyBand;
    private Long authorId;
    private LocalDateTime createdAt;
    private List<QuestionResponse> questions;
}
