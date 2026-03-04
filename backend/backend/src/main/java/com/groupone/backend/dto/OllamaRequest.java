package com.groupone.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class OllamaRequest {
    private String model;
    private String prompt;
    private boolean stream;
}
