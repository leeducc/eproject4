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
public class VocabularyTestSubmissionDTO {
    private List<AnswerDTO> answers;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
class AnswerDTO {
    private Long vocabularyId;
    private boolean isCorrect;
}
