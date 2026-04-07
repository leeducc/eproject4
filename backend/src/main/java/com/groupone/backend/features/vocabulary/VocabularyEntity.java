package com.groupone.backend.features.vocabulary;

import jakarta.persistence.*;
import lombok.*;

import org.hibernate.annotations.SQLRestriction;

@Entity
@Table(name = "vocabulary", indexes = {
    @Index(name = "idx_vocabulary_word", columnList = "word"),
    @Index(name = "idx_vocabulary_type_level", columnList = "type, levelGroup")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@SQLRestriction("is_active = true")
public class VocabularyEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    @Column(nullable = false)
    private String word;

    @Column(nullable = false)
    private String type; 

    private String level; 
    private String levelGroup; 
    private String pos; 
    
    @Column(length = 500)
    private String definitionUrl;
    
    @Column(length = 500)
    private String voiceUrl;

    @Column(columnDefinition = "TEXT")
    private String definition;

    @Column(columnDefinition = "TEXT")
    private String examplesJson;

    @Column(columnDefinition = "TEXT")
    private String synonymsJson;

    private String phonetic;

    @Builder.Default
    private Boolean isPremium = false;
}
