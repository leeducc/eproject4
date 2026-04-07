package com.groupone.backend.features.writing.dto;

import com.groupone.backend.features.quizbank.entity.Question;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TopicResponse {
    private Long id;
    private String title;
    private String prompt;
    private String difficultyBand;
    private String hint;
    private String imageUrl;
    private String audioUrl;
    private Boolean isProOnly;

    public static TopicResponse fromEntity(Question question) {
        if (question == null) return null;
        return TopicResponse.builder()
                .id(question.getId())
                .title("IELTS Writing Task") 
                .prompt(question.getInstruction())
                .difficultyBand(question.getDifficultyBand() != null ? question.getDifficultyBand().name() : null)
                .hint(question.getExplanation())
                .imageUrl(question.getMediaUrl())
                .audioUrl(null) 
                .isProOnly(question.getIsPremiumContent() != null ? question.getIsPremiumContent() : false)
                .build();
    }
}
