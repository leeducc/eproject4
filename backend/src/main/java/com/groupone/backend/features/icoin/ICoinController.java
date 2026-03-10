package com.groupone.backend.features.icoin;

import com.groupone.backend.features.icoin.dto.ICoinBalanceResponse;
import com.groupone.backend.features.identity.User;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/icoin")
public class ICoinController {

    @GetMapping("/balance")
    public ResponseEntity<ICoinBalanceResponse> getBalance(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(new ICoinBalanceResponse(user.getICoinBalance()));
    }
}
