package com.groupone.backend.features.quizbank.dto;

import com.groupone.backend.features.quizbank.enums.ExamSubmissionStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExamSubmissionResponse {
    private Long id;
    private Long examId;
    private String examTitle;
    private Double listeningScore;
    private Double readingScore;
    
    // Derived from writingSubmission
    private Double writingScore;
    private String writingStatus;

    private ExamSubmissionStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime completedAt;
}
