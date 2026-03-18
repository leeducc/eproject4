package com.groupone.backend.features.vocabulary;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VocabularyPracticeHistoryDTO {
    private Long id;
    private Long practiceId;
    private Long editorId;
    private String editorName;
    private String action;
    private String snapshot;
    private Integer version;
    private LocalDateTime createdAt;
}
