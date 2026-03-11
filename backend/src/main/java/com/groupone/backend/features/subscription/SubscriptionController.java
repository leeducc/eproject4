package com.groupone.backend.features.subscription;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.subscription.dto.SubscriptionRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/subscriptions")
@RequiredArgsConstructor
public class SubscriptionController {

    private final SubscriptionService subscriptionService;

    @PostMapping("/purchase")
    public ResponseEntity<Map<String, String>> purchasePro(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody SubscriptionRequest request) {
        
        subscriptionService.purchasePro(user, request);
        return ResponseEntity.ok(Map.of("message", "Successfully purchased Pro subscription."));
    }
}
