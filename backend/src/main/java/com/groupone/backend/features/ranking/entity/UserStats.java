package com.groupone.backend.features.ranking.entity;

import com.groupone.backend.features.identity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_stats")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserStats {

    @Id
    @Column(name = "user_id")
    private Long userId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "total_correct_answers", nullable = false)
    @Builder.Default
    private Long totalCorrectAnswers = 0L;

    @Column(name = "total_vocab_correct", nullable = false)
    @Builder.Default
    private Long totalVocabCorrect = 0L;

    @Column(name = "total_time_seconds", nullable = false)
    @Builder.Default
    private Long totalTimeSeconds = 0L;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
