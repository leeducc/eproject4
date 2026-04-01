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
    private Long id; // Vocabulary ID
    private String word;
    private String quizType; // MULTIPLE_CHOICE, FILL_IN_THE_BLANK, etc.
    private String questionJson; // The specific quiz JSON
}
