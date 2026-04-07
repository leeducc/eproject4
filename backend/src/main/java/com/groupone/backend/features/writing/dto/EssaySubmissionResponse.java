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
    private String status;

    
    private Double taskAchievement;
    private Double cohesionCoherence;
    private Double lexicalResource;
    private Double grammaticalRange;
    private String teacherFeedback;
    private String taskAchievementReason;
    private String cohesionCoherenceReason;
    private String lexicalResourceReason;
    private String grammaticalRangeReason;
    private String correctionsJson;

    public static EssaySubmissionResponse fromEntity(WritingSubmission submission) {
        return EssaySubmissionResponse.builder()
                .id(submission.getId())
                .topic(TopicResponse.fromEntity(submission.getQuestion()))
                .content(submission.getContent())
                .gradingType(submission.getGradingType())
                .aiFeedback(submission.getAiFeedback())
                .score(submission.getScore())
                .createdAt(submission.getCreatedAt())
                .status(submission.getStatus() != null ? submission.getStatus().name() : null)
                .taskAchievement(submission.getTaskAchievement())
                .cohesionCoherence(submission.getCohesionCoherence())
                .lexicalResource(submission.getLexicalResource())
                .grammaticalRange(submission.getGrammaticalRange())
                .teacherFeedback(submission.getTeacherFeedback())
                .taskAchievementReason(submission.getTaskAchievementReason())
                .cohesionCoherenceReason(submission.getCohesionCoherenceReason())
                .lexicalResourceReason(submission.getLexicalResourceReason())
                .grammaticalRangeReason(submission.getGrammaticalRangeReason())
                .correctionsJson(submission.getCorrectionsJson())
                .build();
    }
}
