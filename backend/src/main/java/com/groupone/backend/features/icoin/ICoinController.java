package com.groupone.backend.features.icoin;

import com.groupone.backend.features.icoin.dto.ICoinBalanceResponse;
import com.groupone.backend.features.icoin.dto.ICoinTransactionResponse;
import com.groupone.backend.features.identity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/icoin")
@RequiredArgsConstructor
public class ICoinController {

    private final ICoinService iCoinService;

    @GetMapping("/balance")
    public ResponseEntity<ICoinBalanceResponse> getBalance(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(new ICoinBalanceResponse(user.getICoinBalance()));
    }

    @GetMapping("/history")
    public ResponseEntity<List<ICoinTransactionResponse>> getHistory(@AuthenticationPrincipal User user) {
        List<ICoinTransaction> transactions = iCoinService.getTransactionsByUser(user.getId());
        List<ICoinTransactionResponse> response = transactions.stream()
                .map(t -> ICoinTransactionResponse.builder()
                        .id(t.getId())
                        .amount(t.getAmount())
                        .transactionType(t.getTransactionType())
                        .description(t.getDescription())
                        .balanceAfter(t.getBalanceAfter())
                        .createdAt(t.getCreatedAt())
                        .build())
                .toList();
        return ResponseEntity.ok(response);
    }
}
