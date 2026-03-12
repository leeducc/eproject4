package com.groupone.backend.features.quizbank.dto;

import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class PaginatedResponse<T> {
    private List<T> items;
    private Long nextCursor;
    private boolean hasMore;
}
