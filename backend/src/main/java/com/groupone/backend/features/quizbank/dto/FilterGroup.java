package com.groupone.backend.features.quizbank.dto;

import lombok.Data;
import java.util.List;

@Data
public class FilterGroup {
    private String logic; 
    private List<String> tags; 
}
