package com.groupone.backend.features.writing.dto;

import com.groupone.backend.features.writing.GradingType;
import com.groupone.backend.features.writing.WritingSubmission;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EssaySubmissionResponse {
    private Long id;
    private TopicResponse topic;
    private String content;
    private GradingType gradingType;
    private String aiFeedback;
    private Double score;
    private LocalDateTime createdAt;

    public static EssaySubmissionResponse fromEntity(WritingSubmission submission) {
        return EssaySubmissionResponse.builder()
                .id(submission.getId())
                .topic(TopicResponse.fromEntity(submission.getTopic()))
                .content(submission.getContent())
                .gradingType(submission.getGradingType())
                .aiFeedback(submission.getAiFeedback())
                .score(submission.getScore())
                .createdAt(submission.getCreatedAt())
                .build();
    }
}
