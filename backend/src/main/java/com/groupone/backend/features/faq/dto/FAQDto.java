package com.groupone.backend.features.faq.dto;

import lombok.*;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FAQDto {
    private Long id;
    private String questionEn;
    private String questionVi;
    private String questionZh;
    private String answerEn;
    private String answerVi;
    private String answerZh;
    private Integer displayOrder;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
