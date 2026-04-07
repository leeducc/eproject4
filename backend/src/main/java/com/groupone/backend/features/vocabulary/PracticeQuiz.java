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
    
    private String type; 
    
    
    private String question;
    private List<String> options;
    private String answer;
    
    
    private List<MatchingPair> pairs;
    
    
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
