package com.groupone.backend.features.icoin.dto;

import com.groupone.backend.features.icoin.TransactionType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class TransactionResponse {
    private Long id;
    private Long userId;
    private String userName;
    private String userEmail;
    private Integer amount;
    private TransactionType transactionType;
    private String description;
    private Integer balanceAfter;
    private LocalDateTime createdAt;
}
