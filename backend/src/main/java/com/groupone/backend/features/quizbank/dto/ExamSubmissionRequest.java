package com.groupone.backend.features.quizbank.dto;

import com.groupone.backend.features.quizbank.enums.ExamSubmissionStatus;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExamSubmissionRequest {

    @NotNull(message = "Exam ID is required")
    private Long examId;

    private Double listeningScore;
    
    private Double readingScore;

    private Long writingSubmissionId;

    private ExamSubmissionStatus status;
}
