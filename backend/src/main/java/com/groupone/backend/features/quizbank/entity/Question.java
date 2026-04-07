package com.groupone.backend.features.quizbank.entity;

import com.groupone.backend.features.quizbank.enums.DifficultyBand;
import com.groupone.backend.features.quizbank.enums.QuestionType;
import com.groupone.backend.features.quizbank.enums.SkillType;
import jakarta.persistence.*;
import lombok.*;

import org.hibernate.annotations.SQLRestriction;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "qb_questions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@SQLRestriction("is_active = true")
public class Question {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, columnDefinition = "VARCHAR(255)")
    private SkillType skill;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, columnDefinition = "VARCHAR(255)")
    private QuestionType type;

    @Enumerated(EnumType.STRING)
    @Column(name = "difficulty_band", nullable = false, columnDefinition = "VARCHAR(255)")
    private DifficultyBand difficultyBand;

    @Column(columnDefinition = "TEXT")
    private String data; 

    @Column(name = "is_premium_content", nullable = false)
    @Builder.Default
    private Boolean isPremiumContent = false;

    @Column(columnDefinition = "TEXT")
    private String instruction;

    @Column(columnDefinition = "TEXT")
    private String explanation;
    @Column(name = "media_url", length = 255)
    private String mediaUrl;

    @Column(name = "media_type", length = 50)
    private String mediaType;

    @Column(name = "author_id")
    private Long authorId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "group_id")
    @ToString.Exclude
    private QuestionGroup group;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "qb_question_tags",
        joinColumns = @JoinColumn(name = "question_id"),
        inverseJoinColumns = @JoinColumn(name = "tag_id")
    )
    @Builder.Default
    private List<Tag> tags = new ArrayList<>();
}
