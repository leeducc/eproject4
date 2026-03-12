package com.groupone.backend.features.quizbank.controller;

import com.groupone.backend.features.quizbank.dto.PaginatedResponse;
import com.groupone.backend.features.quizbank.dto.QuestionRequest;
import com.groupone.backend.features.quizbank.dto.QuestionResponse;
import com.groupone.backend.features.quizbank.enums.DifficultyBand;
import com.groupone.backend.features.quizbank.enums.QuestionType;
import com.groupone.backend.features.quizbank.enums.SkillType;
import com.groupone.backend.features.quizbank.service.DataSeederService;
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

    @Autowired
    private DataSeederService dataSeederService;

    @GetMapping("/seed")
    public ResponseEntity<String> seedQuestions(@RequestParam(defaultValue = "100") int count) {
        dataSeederService.seedQuestions(count);
        return ResponseEntity.ok("Successfully seeded " + count + " questions.");
    }

    @GetMapping
    public ResponseEntity<List<QuestionResponse>> getAllQuestions(
            @RequestParam(required = false) SkillType skill) {
        return ResponseEntity.ok(questionBankService.getAllQuestions(skill));
    }

    @GetMapping("/paginated")
    public ResponseEntity<PaginatedResponse<QuestionResponse>> getQuestionsPaginated(
            @RequestParam(required = false) SkillType skill,
            @RequestParam(required = false) QuestionType type,
            @RequestParam(required = false) DifficultyBand difficulty,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Long lastSeenId,
            @RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(questionBankService.getQuestionsPaginated(skill, type, difficulty, search, lastSeenId, limit));
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
