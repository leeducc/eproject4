package com.groupone.backend.features.appconfig.controller;

import com.groupone.backend.features.appconfig.dto.PolicyDto;
import com.groupone.backend.features.appconfig.dto.PolicyHistoryDto;
import com.groupone.backend.features.appconfig.service.PolicyService;
import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class PolicyController {
    private final PolicyService policyService;
    private final UserRepository userRepository;

    private User getCurrentUser() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof User) {
            return (User) principal;
        }

        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("User not found: " + email));
    }

    
    @GetMapping("/policies")
    public ResponseEntity<PolicyDto> getPolicy(@RequestParam String type) {
        return ResponseEntity.ok(policyService.getPolicyByType(type));
    }

    
    @GetMapping("/admin/policies")
    public ResponseEntity<List<PolicyDto>> getAllPolicies() {
        return ResponseEntity.ok(policyService.getAllPolicies());
    }

    @PutMapping("/admin/policies")
    public ResponseEntity<PolicyDto> updatePolicy(@RequestBody PolicyDto dto) {
        User admin = getCurrentUser();
        return ResponseEntity.ok(policyService.updatePolicy(dto, admin));
    }

    @GetMapping("/admin/policies/{type}/history")
    public ResponseEntity<List<PolicyHistoryDto>> getPolicyHistory(@PathVariable String type) {
        return ResponseEntity.ok(policyService.getPolicyHistory(type));
    }
}
