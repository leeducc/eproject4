package com.groupone.backend.features.smarttest.entity;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.quizbank.entity.Question;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_question_attempts", indexes = {
    @Index(name = "idx_user_question_perf", columnList = "user_id, question_id")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserQuestionAttempt {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @ToString.Exclude
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id")
    @ToString.Exclude
    private UserTestSession session;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id", nullable = false)
    @ToString.Exclude
    private Question question;

    @Column(name = "user_answer", columnDefinition = "TEXT")
    private String userAnswer;

    @Column(name = "is_correct", nullable = false)
    private Boolean isCorrect;

    @CreationTimestamp
    @Column(name = "attempt_date", nullable = false, updatable = false)
    private LocalDateTime attemptDate;
}
