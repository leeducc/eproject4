package com.groupone.backend.features.subscription.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class SubscriptionRequest {
    @NotNull
    @Min(1)
    private Integer months;

    @NotNull
    @Min(0)
    private Integer priceICoins;
}
