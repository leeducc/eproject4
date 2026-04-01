package com.groupone.backend.features.ranking.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LeaderboardEntryDto {
    private int rank;
    private Long userId;
    private String displayName;
    private String avatarUrl;
    private boolean isPro;
    private long score;
}
