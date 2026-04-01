package com.groupone.backend.features.appconfig.controller;

import com.groupone.backend.features.appconfig.dto.PolicyDto;
import com.groupone.backend.features.appconfig.service.PolicyService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class PolicyController {
    private final PolicyService policyService;

    // Public endpoint for mobile
    @GetMapping("/policies")
    public ResponseEntity<PolicyDto> getPolicy(@RequestParam String type) {
        return ResponseEntity.ok(policyService.getPolicyByType(type));
    }

    // Admin endpoints
    @GetMapping("/admin/policies")
    public ResponseEntity<List<PolicyDto>> getAllPolicies() {
        return ResponseEntity.ok(policyService.getAllPolicies());
    }

    @PutMapping("/admin/policies")
    public ResponseEntity<PolicyDto> updatePolicy(@RequestBody PolicyDto dto) {
        return ResponseEntity.ok(policyService.updatePolicy(dto));
    }
}
