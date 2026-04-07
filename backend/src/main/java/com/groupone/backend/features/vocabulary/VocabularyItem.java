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
    private String type; 
    private String level; 
    private String levelGroup; 
    private String pos; 
    private String definitionUrl;
    private String voiceUrl;

    
    private String definition;
    private java.util.List<String> examples;
    private java.util.List<String> synonyms;

    private String phonetic;
    private Boolean isPremium;
    private Boolean isFavorite;

    
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
                .examples(java.util.Collections.emptyList()) 
                .synonyms(java.util.Collections.emptyList())
                .build();
    }
}
