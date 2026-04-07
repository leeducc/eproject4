package com.groupone.backend.features.icoin.dto;

import com.groupone.backend.features.icoin.TransactionType;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonFormat;

@Data
@Builder
public class ICoinTransactionResponse {
    private Long id;
    private Integer amount;
    private TransactionType transactionType;
    private String description;
    private Integer balanceAfter;
    @JsonFormat(pattern = "HH:mm dd/MM/yyyy")
    private LocalDateTime createdAt;
}
