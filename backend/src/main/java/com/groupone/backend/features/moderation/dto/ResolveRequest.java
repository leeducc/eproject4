package com.groupone.backend.features.moderation.dto;

import lombok.Data;

@Data
public class ResolveRequest {
    private String adminResponse;
    private boolean disableContent;
}
