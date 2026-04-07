package com.groupone.backend.features.quizbank.dto;

import lombok.Data;
import java.util.List;

@Data
public class FilterRequest {
    private String logic; 
    private String skill; 
    private List<FilterGroup> groups;
}
