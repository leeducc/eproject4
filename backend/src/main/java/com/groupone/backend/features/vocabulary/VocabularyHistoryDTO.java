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
public class VocabularyHistoryDTO {
    private Long id;
    private Long vocabularyId;
    private Long editorId;
    private String editorName;
    private String action;
    private String snapshot;
    private String changes;
    private LocalDateTime createdAt;
}
