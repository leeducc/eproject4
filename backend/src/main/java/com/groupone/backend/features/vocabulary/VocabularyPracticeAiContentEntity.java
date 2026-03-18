package com.groupone.backend.features.vocabulary;

import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "vocabulary_practice_ai_generated_content", indexes = {
    @Index(name = "idx_vocab_practice_ai_word_type", columnList = "word, quiz_type")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VocabularyPracticeAiContentEntity implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String word;

    @Column(name = "quiz_type", nullable = false)
    private String quizType; // MULTIPLE_CHOICE, MATCHING, FILL_IN_THE_BLANK

    @Column(columnDefinition = "LONGTEXT", nullable = false)
    private String jsonContent;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Builder.Default
    @Column(name = "version")
    private Integer version = 1;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
