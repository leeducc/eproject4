package com.groupone.backend.features.quizbank.controller;

import com.groupone.backend.features.quizbank.dto.ExamSubmissionRequest;
import com.groupone.backend.features.quizbank.dto.ExamSubmissionResponse;
import com.groupone.backend.features.quizbank.service.ExamSubmissionService;
import com.groupone.backend.features.identity.User;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/exams")
public class ExamSubmissionController {

    @Autowired
    private ExamSubmissionService examSubmissionService;

    @PostMapping("/submit")
    public ResponseEntity<ExamSubmissionResponse> submitExam(
            @Valid @RequestBody ExamSubmissionRequest request,
            @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(examSubmissionService.submitExam(request, user));
    }

    @GetMapping("/my-submissions")
    public ResponseEntity<List<ExamSubmissionResponse>> getMySubmissions(
            @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(examSubmissionService.getMySubmissions(user));
    }
}
