package com.groupone.backend.features.icoin;

import com.groupone.backend.features.icoin.dto.AdminICoinRequest;
import com.groupone.backend.features.icoin.dto.ICoinBalanceResponse;
import com.groupone.backend.features.icoin.dto.TransactionResponse;
import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
public class AdminICoinController {

    private final ICoinService iCoinService;
    private final UserRepository userRepository;

    // ── List all transactions ─────────────────────────────────────────────────
    @GetMapping("/api/admin/icoin/transactions")
    public ResponseEntity<List<TransactionResponse>> getAllTransactions() {
        List<TransactionResponse> result = iCoinService.getAllTransactions().stream()
                .map(t -> TransactionResponse.builder()
                        .id(t.getId())
                        .userId(t.getUser().getId())
                        .userName(t.getUser().getProfile() != null ? t.getUser().getProfile().getFullName() : null)
                        .userEmail(t.getUser().getEmail())
                        .amount(t.getAmount())
                        .transactionType(t.getTransactionType())
                        .description(t.getDescription())
                        .balanceAfter(t.getBalanceAfter())
                        .createdAt(t.getCreatedAt())
                        .build())
                .collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }

    // ── Per-user balance operations ───────────────────────────────────────────
    @GetMapping("/api/admin/users/{userId}/icoin")
    public ResponseEntity<ICoinBalanceResponse> getBalance(@PathVariable Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return ResponseEntity.ok(new ICoinBalanceResponse(user.getICoinBalance()));
    }

    @PostMapping("/api/admin/users/{userId}/icoin/add")
    public ResponseEntity<Void> addICoin(@PathVariable Long userId, @RequestBody AdminICoinRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        iCoinService.addICoin(user, request.getAmount(), request.getDescription());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/api/admin/users/{userId}/icoin/deduct")
    public ResponseEntity<Void> deductICoin(@PathVariable Long userId, @RequestBody AdminICoinRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        iCoinService.deductICoin(user, request.getAmount(), request.getDescription());
        return ResponseEntity.ok().build();
    }

    @PutMapping("/api/admin/users/{userId}/icoin/set")
    public ResponseEntity<Void> setICoin(@PathVariable Long userId, @RequestBody AdminICoinRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        iCoinService.setICoinBalance(user, request.getAmount(), request.getDescription());
        return ResponseEntity.ok().build();
    }
}
