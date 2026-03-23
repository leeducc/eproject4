package com.groupone.backend.features.vocabulary;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "vocabulary_history")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VocabularyHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "vocabulary_id", nullable = false)
    private Long vocabularyId;

    @Column(name = "editor_id", nullable = false)
    private Long editorId;

    @Column(nullable = false)
    private String action; // CREATED, UPDATED, ROLLBACK

    @Column(columnDefinition = "TEXT")
    private String snapshot; // JSON snapshot of the vocabulary data

    @Column(columnDefinition = "TEXT")
    private String changes; // JSON representation of changes

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
