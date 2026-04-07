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
    private String action; 

    @Column(columnDefinition = "TEXT")
    private String snapshot; 

    @Column(columnDefinition = "TEXT")
    private String changes; 

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
