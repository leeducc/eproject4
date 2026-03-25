package com.groupone.backend.features.quizbank.entity;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.quizbank.enums.ExamSubmissionStatus;
import com.groupone.backend.features.writing.WritingSubmission;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "qb_exam_submissions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExamSubmission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "exam_id", nullable = false)
    private Exam exam;

    private Double listeningScore;
    
    private Double readingScore;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "writing_submission_id")
    private WritingSubmission writingSubmission;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, columnDefinition = "VARCHAR(255)")
    @Builder.Default
    private ExamSubmissionStatus status = ExamSubmissionStatus.IN_PROGRESS;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
    
    @Column(name = "completed_at")
    private LocalDateTime completedAt;
}
