package com.groupone.backend.features.vocabulary;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VocabularyTestDTO {
    private List<TestQuestionDTO> questions;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
class TestQuestionDTO {
    private Long id; 
    private String word;
    private String quizType; 
    private String questionJson; 
}
