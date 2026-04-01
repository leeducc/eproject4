package com.groupone.backend.features.vocabulary;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VocabularyDetail implements Serializable {
    private static final long serialVersionUID = 1L;
    private String definition;
    private String phonetic;
    private List<String> examples;
    private List<String> synonyms;
}
