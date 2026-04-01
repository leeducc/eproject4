package com.groupone.backend.features.ranking.entity;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.appconfig.entity.AppScreenSection;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_section_stats", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"user_id", "section_id"})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserSectionStats {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "section_id", nullable = false)
    private AppScreenSection section;

    @Column(name = "total_correct_answers", nullable = false)
    @Builder.Default
    private Integer totalCorrectAnswers = 0;

    @Column(name = "total_questions_attempted", nullable = false)
    @Builder.Default
    private Integer totalQuestionsAttempted = 0;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
