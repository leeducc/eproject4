package com.groupone.backend.features.appconfig.dto;

import lombok.Data;

@Data
public class AppScreenSectionRequest {
    private String skill;
    private String sectionName;
    private String difficultyBand;
    private Integer displayOrder;
    private java.util.List<Long> tagIds;
    private String guideContent;
}
