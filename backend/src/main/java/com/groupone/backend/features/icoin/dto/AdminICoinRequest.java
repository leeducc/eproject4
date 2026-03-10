package com.groupone.backend.features.icoin.dto;

import lombok.Data;

@Data
public class AdminICoinRequest {
    private Integer amount;
    private String description;
}
