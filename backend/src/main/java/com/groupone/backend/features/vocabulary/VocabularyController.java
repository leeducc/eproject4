package com.groupone.backend.features.vocabulary;

import com.groupone.backend.features.quizbank.dto.PaginatedResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/v1/vocabulary")
@RequiredArgsConstructor
public class VocabularyController {

    private final VocabularyService vocabularyService;
    private final AiContentService aiContentService;

    @GetMapping
    public ResponseEntity<PaginatedResponse<VocabularyItem>> getVocabulary(
            @RequestParam(defaultValue = "words") String type,
            @RequestParam(required = false) String levelGroup,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Long lastSeenId,
            @RequestParam(defaultValue = "20") int limit) {
        
        log.info("Request: GET paginated vocabulary type={}, levelGroup={}, search={}, lastSeenId={}, limit={}", 
                type, levelGroup, search, lastSeenId, limit);
        PaginatedResponse<VocabularyItem> response = vocabularyService.getVocabularyPaginated(type, levelGroup, search, lastSeenId, limit);
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<VocabularyItem> createWord(@RequestBody VocabularyItem item) {
        log.info("Request: POST create vocabulary word={}", item.getWord());
        return ResponseEntity.ok(vocabularyService.createVocabulary(item));
    }

    @PutMapping("/{id}")
    public ResponseEntity<VocabularyItem> updateWord(@PathVariable Long id, @RequestBody VocabularyItem item) {
        log.info("Request: PUT update vocabulary id={}", id);
        return ResponseEntity.ok(vocabularyService.updateVocabulary(id, item));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteWord(@PathVariable Long id) {
        log.info("Request: DELETE vocabulary id={}", id);
        vocabularyService.deleteVocabulary(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{word}/details")
    public ResponseEntity<VocabularyDetail> getWordDetails(@PathVariable String word) {
        log.info("Request: GET details for word={}", word);
        try {
            VocabularyDetail details = aiContentService.generateDetails(word);
            return ResponseEntity.ok(details);
        } catch (Exception e) {
            log.error("Error generating word details for {}: {}", word, e.getMessage());
            return ResponseEntity.internalServerError().build();
        }
    }

    @PostMapping("/{word}/ensure-ai-content")
    public ResponseEntity<Void> ensureAiContent(@PathVariable String word) {
        log.info("Request: POST ensure AI content for word={}", word);
        try {
            aiContentService.ensureAiContent(word);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("Error ensuring AI content for {}: {}", word, e.getMessage());
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/{word}/practice")
    public ResponseEntity<PracticeQuiz> getWordPractice(@PathVariable String word) {
        log.info("Request: GET practice for word={}", word);
        try {
            PracticeQuiz practice = aiContentService.generatePractice(word);
            return ResponseEntity.ok(practice);
        } catch (Exception e) {
            log.error("Error generating practice questions for {}: {}", word, e.getMessage());
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/{word}/practice/all")
    public ResponseEntity<List<VocabularyPracticeAiContentEntity>> getAllPractice(@PathVariable String word) {
        log.info("Request: GET all practice for word={}", word);
        return ResponseEntity.ok(vocabularyService.getPracticeByWord(word));
    }

    @PutMapping("/practice/{id}")
    public ResponseEntity<Void> updatePractice(@PathVariable Long id, @RequestBody String jsonContent) {
        log.info("Request: PUT update practice id={}", id);
        vocabularyService.updatePractice(id, jsonContent);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/practice/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deletePractice(@PathVariable Long id) {
        log.info("Request: DELETE practice id={}", id);
        vocabularyService.deletePractice(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/practice/{word}")
    public ResponseEntity<VocabularyPracticeAiContentEntity> createManualPractice(@PathVariable String word, @RequestBody PracticeQuiz practice) {
        log.info("Request: POST manual practice for word={}", word);
        return ResponseEntity.ok(vocabularyService.createPractice(word, practice));
    }
    @GetMapping("/{id}/history")
    public ResponseEntity<List<VocabularyHistoryDTO>> getWordHistory(@PathVariable Long id) {
        log.info("Request: GET history for vocabulary id={}", id);
        return ResponseEntity.ok(vocabularyService.getWordHistory(id));
    }

    @GetMapping("/practice/{id}/history")
    public ResponseEntity<List<VocabularyPracticeHistoryDTO>> getPracticeHistory(@PathVariable Long id) {
        log.info("Request: GET history for practice id={}", id);
        return ResponseEntity.ok(vocabularyService.getPracticeHistory(id));
    }

    @PostMapping("/history/{historyId}/rollback")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> rollbackWordToVersion(@PathVariable Long historyId) {
        log.info("Request: POST rollback vocabulary to version id={}", historyId);
        vocabularyService.rollbackToVersion(historyId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/practice/history/{historyId}/rollback")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> rollbackPracticeToVersion(@PathVariable Long historyId) {
        log.info("Request: POST rollback practice to version id={}", historyId);
        vocabularyService.rollbackPracticeToVersion(historyId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/import")
    public ResponseEntity<Map<String, Object>> importVocabulary(@RequestParam("file") MultipartFile file) {
        int count = vocabularyService.importFromExcel(file);
        return ResponseEntity.ok(Map.of(
            "message", "Successfully imported " + count + " entries",
            "count", count
        ));
    }

    @GetMapping("/sample")
    public ResponseEntity<byte[]> getSampleExcel() {
        byte[] data = vocabularyService.generateSampleExcel();
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=vocabulary_sample.xlsx")
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .body(data);
    }
}
