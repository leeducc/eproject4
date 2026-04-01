package com.groupone.backend.features.moderation.dto;

import com.groupone.backend.features.moderation.enums.ReportedItemType;
import lombok.Data;

@Data
public class ReportRequest {
    private ReportedItemType itemType;
    private Long itemId;
    private String reason;
}
