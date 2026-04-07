package com.groupone.backend.features.quizbank.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "qb_question_history")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuestionHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "question_id", nullable = false)
    private Long questionId;

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
