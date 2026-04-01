package com.groupone.backend.features.appconfig.dto;

import lombok.*;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PolicyDto {
    private Long id;
    private String type;
    private String titleEn;
    private String titleVi;
    private String titleZh;
    private String contentEn;
    private String contentVi;
    private String contentZh;
    private LocalDateTime updatedAt;
}
