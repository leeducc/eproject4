package com.groupone.backend.features.quizbank.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class QuestionHistoryResponse {
    private Long id;
    private Long questionId;
    private Long editorId;
    private String editorEmail;
    private String action;
    private String snapshot;
    private String changes;
    private LocalDateTime createdAt;
}
