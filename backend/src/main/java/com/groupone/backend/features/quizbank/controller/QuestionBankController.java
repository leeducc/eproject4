package com.groupone.backend.features.quizbank.controller;

import com.groupone.backend.features.quizbank.dto.QuestionRequest;
import com.groupone.backend.features.quizbank.dto.QuestionResponse;
import com.groupone.backend.features.quizbank.enums.SkillType;
import com.groupone.backend.features.quizbank.service.QuestionBankService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/questions")
public class QuestionBankController {

    @Autowired
    private QuestionBankService questionBankService;

    @GetMapping
    public ResponseEntity<List<QuestionResponse>> getAllQuestions(
            @RequestParam(required = false) SkillType skill) {
        return ResponseEntity.ok(questionBankService.getAllQuestions(skill));
    }

    @GetMapping("/{id}")
    public ResponseEntity<QuestionResponse> getQuestionById(@PathVariable Long id) {
        return ResponseEntity.ok(questionBankService.getQuestionById(id));
    }

    @PostMapping(consumes = { "multipart/form-data" })
    public ResponseEntity<QuestionResponse> createQuestion(
            @RequestPart("question") @Valid QuestionRequest request,
            @RequestPart(value = "media", required = false) List<org.springframework.web.multipart.MultipartFile> media) {
        return ResponseEntity.ok(questionBankService.createQuestion(request, media));
    }

    @PutMapping(value = "/{id}", consumes = { "multipart/form-data" })
    public ResponseEntity<QuestionResponse> updateQuestion(
            @PathVariable Long id, 
            @RequestPart("question") @Valid QuestionRequest request,
            @RequestPart(value = "media", required = false) List<org.springframework.web.multipart.MultipartFile> media) {
        return ResponseEntity.ok(questionBankService.updateQuestion(id, request, media));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteQuestion(@PathVariable Long id) {
        questionBankService.deleteQuestion(id);
        return ResponseEntity.noContent().build();
    }
}
