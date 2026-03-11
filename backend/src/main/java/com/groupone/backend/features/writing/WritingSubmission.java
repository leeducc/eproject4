package com.groupone.backend.features.writing;

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
    private WritingTopic topic;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private GradingType gradingType;

    @Column(columnDefinition = "TEXT")
    private String aiFeedback;

    private Double score;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
}
