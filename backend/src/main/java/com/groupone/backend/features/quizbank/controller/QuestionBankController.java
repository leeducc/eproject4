package com.groupone.backend.features.quizbank.controller;

import com.groupone.backend.features.quizbank.dto.*;
import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.enums.DifficultyBand;
import com.groupone.backend.features.quizbank.enums.QuestionType;
import com.groupone.backend.features.quizbank.enums.SkillType;
import com.groupone.backend.features.quizbank.service.DataSeederService;
import com.groupone.backend.features.quizbank.service.QuestionBankService;
import com.groupone.backend.features.quizbank.service.QuestionFilterService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

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
            @RequestParam(required = false) Long authorId,
            @RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(questionBankService.getQuestionsPaginated(skill, type, difficulty, search, lastSeenId, authorId, limit));
    }

    @GetMapping("/{id}")
    public ResponseEntity<QuestionResponse> getQuestionById(@PathVariable Long id) {
        return ResponseEntity.ok(questionBankService.getQuestionById(id));
    }

    @GetMapping("/{id}/history")
    public ResponseEntity<List<QuestionHistoryResponse>> getQuestionHistory(@PathVariable Long id) {
        return ResponseEntity.ok(questionBankService.getQuestionHistory(id));
    }

    @PostMapping("/history/{historyId}/rollback")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> rollbackQuestion(@PathVariable Long historyId) {
        questionBankService.rollbackToVersion(historyId);
        return ResponseEntity.ok().build();
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

    @PostMapping("/import")
    public ResponseEntity<String> importQuestions(@RequestParam("file") MultipartFile file) throws IOException {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("Please upload a file.");
        }
        questionBankService.importQuestions(file.getInputStream());
        return ResponseEntity.ok("Questions imported successfully.");
    }

    @GetMapping("/export")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<byte[]> exportQuestions() throws IOException {
        byte[] excelData = questionBankService.exportQuestions();
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=questions.xlsx")
                .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .body(excelData);
    }

    @GetMapping("/sample-excel")
    public ResponseEntity<byte[]> getSampleExcel() throws IOException {
        
        try (org.apache.poi.ss.usermodel.Workbook workbook = new org.apache.poi.xssf.usermodel.XSSFWorkbook(); 
             java.io.ByteArrayOutputStream out = new java.io.ByteArrayOutputStream()) {
            org.apache.poi.ss.usermodel.Sheet sheet = workbook.createSheet("Sample Questions");
            String[] headers = {"id", "skill", "type", "difficulty_band", "instruction", "explanation", "is_premium_content", "media_type", "media_url", "question_prompt", "options_or_matches", "correct_answer"};
            org.apache.poi.ss.usermodel.Row headerRow = sheet.createRow(0);
            for (int i = 0; i < headers.length; i++) headerRow.createCell(i).setCellValue(headers[i]);
            
            Object[][] data = {
                {"", "VOCABULARY", "MULTIPLE_CHOICE", "BAND_0_4", "Choose synonym.", "", 0, "", "", "Synonym of Happy?", "Sad | Cheerful", "Cheerful"},
                {"", "READING", "MATCHING", "BAND_5_6", "Match sounds.", "", 1, "", "", "Cat | Dog", "Meow | Woof", "Cat-Meow | Dog-Woof"},
                {"", "WRITING", "ESSAY", "BAND_7_8", "Climate opinion.", "", 0, "", "", "What is your opinion on climate change?", "", "Sample rubric"},
                {"", "WRITING", "ESSAY", "BAND_9", "Climate essay.", "", 1, "", "", "Discuss climate change.", "", "Sample rubric"}
            };
            for (int i = 0; i < data.length; i++) {
                org.apache.poi.ss.usermodel.Row row = sheet.createRow(i + 1);
                for (int j = 0; j < data[i].length; j++) row.createCell(j).setCellValue(data[i][j].toString());
            }
            workbook.write(out);
            return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=sample_questions.xlsx")
                .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .body(out.toByteArray());
        }
    }

    @Autowired
    private QuestionFilterService questionFilterService;

    @PostMapping("/filter")
    public ResponseEntity<List<QuestionResponse>> filterQuestions(@RequestBody FilterRequest request) {
        List<Question> questions = questionFilterService.filterQuestions(request);
        return ResponseEntity.ok(questions.stream()
                .map(questionBankService::mapToResponse)
                .collect(Collectors.toList()));
    }
}
