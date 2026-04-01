package com.groupone.backend.features.ranking.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MyRankResponse {
    private Long userId;
    private long myRank;
    private long myScore;
    private boolean ranked; // false if user has 0 score (never played)
}
