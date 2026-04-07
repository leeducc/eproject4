package com.groupone.backend.features.vocabulary;

import com.groupone.backend.features.identity.User;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_word_progress", indexes = {
    @Index(name = "idx_uwp_user_vocab", columnList = "user_id, vocabulary_id"),
    @Index(name = "idx_uwp_next_review", columnList = "next_review_date")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserWordProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vocabulary_id", nullable = false)
    private VocabularyEntity vocabulary;

    @Column(name = "proficiency_level", nullable = false)
    @Builder.Default
    private Integer proficiencyLevel = 0; 

    @Column(name = "next_review_date")
    private LocalDateTime nextReviewDate;

    @Column(name = "is_viewed", nullable = false)
    @Builder.Default
    private boolean isViewed = true;

    @Column(name = "correct_streak", nullable = false)
    @Builder.Default
    private Integer correctStreak = 0;

    @Column(name = "last_reviewed_at")
    private LocalDateTime lastReviewedAt;
}
