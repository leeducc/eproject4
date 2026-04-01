package com.groupone.backend.features.smarttest.controller;

import com.groupone.backend.features.quizbank.dto.QuestionResponse;
import com.groupone.backend.features.smarttest.dto.SmartTestSubmitRequest;
import com.groupone.backend.features.smarttest.dto.SmartTestSubmitResponse;
import com.groupone.backend.features.smarttest.service.SmartTestService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/tests")
@RequiredArgsConstructor
public class SmartTestController {

    private final SmartTestService service;

    @GetMapping("/smart-generate")
    public ResponseEntity<List<QuestionResponse>> generateSmartTest(
            @RequestParam String skill,
            @RequestParam String level) {
        return ResponseEntity.ok(service.generateSmartTest(skill, level));
    }

    @PostMapping("/submit")
    public ResponseEntity<SmartTestSubmitResponse> submitSmartTest(
            @RequestBody SmartTestSubmitRequest request) {
        return ResponseEntity.ok(service.submitSmartTest(request));
    }
}
