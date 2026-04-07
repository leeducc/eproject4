package com.groupone.backend.features.appconfig.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PolicyHistoryDto {
    private Long id;
    private String type;
    private String titleEn;
    private String titleVi;
    private String titleZh;
    private String contentEn;
    private String contentVi;
    private String contentZh;
    private Long adminId;
    private String adminEmail;
    private LocalDateTime changedAt;
}
