package com.groupone.backend.features.quizbank.dto;

import lombok.Data;
import java.util.List;

@Data
public class FilterGroup {
    private String logic; // "AND" or "OR"
    private List<String> tags; // e.g., "UI:TFNG", "Topic:Science"
}
