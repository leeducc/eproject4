package com.groupone.backend.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class OllamaResponse {
    private String model;
    private String created_at;
    private String response;
    private boolean done;
}
