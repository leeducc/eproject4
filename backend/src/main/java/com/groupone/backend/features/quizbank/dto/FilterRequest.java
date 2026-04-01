package com.groupone.backend.features.quizbank.dto;

import lombok.Data;
import java.util.List;

@Data
public class FilterRequest {
    private String logic; // "AND" or "OR"
    private String skill; // "LISTENING" or "READING"
    private List<FilterGroup> groups;
}
