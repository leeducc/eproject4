package com.groupone.backend.features.vocabulary;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "vocabulary_practice_history")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VocabularyPracticeHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "practice_id", nullable = false)
    private Long practiceId;

    @Column(name = "editor_id", nullable = false)
    private Long editorId;

    @Column(nullable = false)
    private String action; // CREATED, UPDATED, ROLLBACK

    @Column(columnDefinition = "TEXT")
    private String snapshot; // JSON snapshot of the practice data

    @Column(columnDefinition = "TEXT")
    private String changes; // JSON representation of changes

    @Column(name = "version")
    private Integer version;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
