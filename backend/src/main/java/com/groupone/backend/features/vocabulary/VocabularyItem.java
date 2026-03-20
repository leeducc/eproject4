package com.groupone.backend.features.vocabulary;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VocabularyItem {
    private Long id;
    private String word;
    private String type; // 'word' or 'phrase'
    private String level; // Original CEFR (A1, A2, B1, B2, C1, C2)
    private String levelGroup; // IELTS-style (0-4, 5-6, 7-8, 9)
    private String pos; // Part of Speech
    private String definitionUrl;
    private String voiceUrl;

    // AI Contents
    private String definition;
    private java.util.List<String> examples;
    private java.util.List<String> synonyms;

    // Assuming VocabularyEntity exists and has corresponding getters
    public static VocabularyItem mapToItem(VocabularyEntity entity) {
        return VocabularyItem.builder()
                .id(entity.getId())
                .word(entity.getWord())
                .type(entity.getType())
                .level(entity.getLevel())
                .levelGroup(entity.getLevelGroup())
                .pos(entity.getPos())
                .definitionUrl(entity.getDefinitionUrl())
                .voiceUrl(entity.getVoiceUrl())
                .definition(entity.getDefinition())
                .examples(java.util.Collections.emptyList()) // Manual mapping doesn't have objectMapper
                .synonyms(java.util.Collections.emptyList())
                .build();
    }
}
