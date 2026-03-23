package com.groupone.backend.features.writing;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.quizbank.entity.Question;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "essay_submission")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WritingSubmission {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "topic_id", nullable = false)
    private Question question;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private GradingType gradingType;

    @Column(columnDefinition = "TEXT")
    private String aiFeedback;

    private Double score;

    // IELTS Criteria scores
    private Double taskAchievement;
    private Double cohesionCoherence;
    private Double lexicalResource;
    private Double grammaticalRange;

    @Column(columnDefinition = "TEXT")
    private String teacherFeedback;

    @Column(columnDefinition = "TEXT")
    private String taskAchievementReason;
    
    @Column(columnDefinition = "TEXT")
    private String cohesionCoherenceReason;
    
    @Column(columnDefinition = "TEXT")
    private String lexicalResourceReason;
    
    @Column(columnDefinition = "TEXT")
    private String grammaticalRangeReason;

    @Column(columnDefinition = "TEXT")
    private String correctionsJson;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private SubmissionStatus status = SubmissionStatus.PENDING;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "locked_by")
    private User lockedBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id")
    private User student;

    private LocalDateTime lockedAt;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
}
