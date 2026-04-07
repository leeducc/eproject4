package com.groupone.backend.features.writing.dto;

import com.groupone.backend.features.writing.SubmissionStatus;
import com.groupone.backend.features.writing.WritingSubmission;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SubmissionSummaryResponse {
    private Long id;
    private String studentName;
    private String taskType;
    private LocalDateTime submissionDate;
    private SubmissionStatus status;
    private String lockedBy;
    private Long lockedById;
    private String content;
    private String prompt;
    private IELTSScoresDto scores;
    private Double overallBand;
    private String feedback;
    private List<CorrectionDto> corrections;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class IELTSScoresDto {
        private Double taskAchievement;
        private String taskAchievementReason;
        private Double cohesionCoherence;
        private String cohesionCoherenceReason;
        private Double lexicalResource;
        private String lexicalResourceReason;
        private Double grammaticalRange;
        private String grammaticalRangeReason;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CorrectionDto {
        private String id;
        private Integer start;
        private Integer end;
        private String text;
        private String suggestion;
        private String note;
    }

    public static SubmissionSummaryResponse fromEntity(WritingSubmission submission) {
        String taskType = "Unknown";
        String prompt = "No instruction provided.";
        try {
            if (submission.getQuestion() != null) {
                if (submission.getQuestion().getType() != null) {
                    taskType = submission.getQuestion().getType().name();
                }
                if (submission.getQuestion().getInstruction() != null) {
                    prompt = submission.getQuestion().getInstruction();
                }
            }
        } catch (jakarta.persistence.EntityNotFoundException e) {
            System.err.println("Question not found for submission ID: " + submission.getId());
        }

        String studentName = "Anonymous Student";
        if (submission.getStudent() != null) {
            if (submission.getStudent().getProfile() != null && submission.getStudent().getProfile().getFullName() != null) {
                studentName = submission.getStudent().getProfile().getFullName();
            } else {
                studentName = submission.getStudent().getEmail();
            }
        }

        IELTSScoresDto scoresDto = IELTSScoresDto.builder()
                .taskAchievement(submission.getTaskAchievement() != null ? submission.getTaskAchievement() : 0.0)
                .taskAchievementReason(submission.getTaskAchievementReason())
                .cohesionCoherence(submission.getCohesionCoherence() != null ? submission.getCohesionCoherence() : 0.0)
                .cohesionCoherenceReason(submission.getCohesionCoherenceReason())
                .lexicalResource(submission.getLexicalResource() != null ? submission.getLexicalResource() : 0.0)
                .lexicalResourceReason(submission.getLexicalResourceReason())
                .grammaticalRange(submission.getGrammaticalRange() != null ? submission.getGrammaticalRange() : 0.0)
                .grammaticalRangeReason(submission.getGrammaticalRangeReason())
                .build();

        
        List<CorrectionDto> correctionsList = new ArrayList<>();
        if (submission.getCorrectionsJson() != null && !submission.getCorrectionsJson().isEmpty()) {
            try {
                ObjectMapper mapper = new ObjectMapper();
                correctionsList = mapper.readValue(submission.getCorrectionsJson(), 
                    new TypeReference<List<CorrectionDto>>() {});
            } catch (Exception e) {
                System.err.println("Error parsing corrections JSON: " + e.getMessage());
            }
        }

        return SubmissionSummaryResponse.builder()
                .id(submission.getId())
                .studentName(studentName)
                .taskType(taskType)
                .submissionDate(submission.getCreatedAt() != null ? submission.getCreatedAt() : LocalDateTime.now())
                .status(submission.getStatus())
                .lockedBy(submission.getLockedBy() != null ? submission.getLockedBy().getEmail() : null)
                .lockedById(submission.getLockedBy() != null ? submission.getLockedBy().getId() : null)
                .content(submission.getContent())
                .prompt(prompt)
                .scores(scoresDto)
                .overallBand(submission.getScore())
                .feedback(submission.getTeacherFeedback())
                .corrections(correctionsList)
                .build();
    }
}
