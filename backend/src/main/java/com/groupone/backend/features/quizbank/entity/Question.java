package com.groupone.backend.features.quizbank.entity;

import com.groupone.backend.features.quizbank.enums.DifficultyBand;
import com.groupone.backend.features.quizbank.enums.QuestionType;
import com.groupone.backend.features.quizbank.enums.SkillType;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "qb_questions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Question {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SkillType skill;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private QuestionType type;

    @Enumerated(EnumType.STRING)
    @Column(name = "difficulty_band", nullable = false)
    private DifficultyBand difficultyBand;

    @Column(columnDefinition = "TEXT")
    private String data; // JSON blob for options, blanks, etc.

    @Column(name = "is_premium_content", nullable = false)
    @Builder.Default
    private Boolean isPremiumContent = false;

    @Column(columnDefinition = "TEXT")
    private String instruction;

    @Column(columnDefinition = "TEXT")
    private String explanation;
}
