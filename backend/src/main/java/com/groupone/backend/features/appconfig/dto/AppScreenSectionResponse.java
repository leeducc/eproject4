package com.groupone.backend.features.appconfig.dto;

import com.groupone.backend.features.quizbank.entity.Tag;
import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class AppScreenSectionResponse {
    private Long id;
    private String skill;
    private String sectionName;
    private String difficultyBand;
    private Integer displayOrder;
    private List<Tag> tags;
    private String guideContent;
    private Integer questionCount;
    private Double mastery;
}
