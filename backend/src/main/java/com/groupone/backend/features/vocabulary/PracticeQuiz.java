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
public class PracticeQuiz implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private String type; // MULTIPLE_CHOICE, MATCHING, FILL_IN_THE_BLANK
    
    // Multiple Choice & Fill In The Blank
    private String question;
    private List<String> options;
    private String answer;
    
    // Matching
    private List<MatchingPair> pairs;
    
    // Fill In The Blank specific (optional, can reuse question)
    private String sentence;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MatchingPair implements Serializable {
        private static final long serialVersionUID = 1L;
        private String word;
        private String meaning;
    }
}
