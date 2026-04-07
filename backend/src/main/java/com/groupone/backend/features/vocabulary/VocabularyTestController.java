package com.groupone.backend.features.vocabulary;

import com.groupone.backend.features.identity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/api/v1/vocabulary/test")
@RequiredArgsConstructor
public class VocabularyTestController {

    private final VocabularyTestService testService;

    @GetMapping("/due-count")
    public ResponseEntity<Integer> getDueCount() {
        Long userId = getCurrentUserId();
        return ResponseEntity.ok(testService.getDueCount(userId));
    }

    @GetMapping("/generate")
    public ResponseEntity<VocabularyTestDTO> generateTest() {
        Long userId = getCurrentUserId();
        return ResponseEntity.ok(testService.generateTest(userId));
    }

    @PostMapping("/submit")
    public ResponseEntity<Void> submitResults(@RequestBody VocabularyTestSubmissionDTO submission) {
        Long userId = getCurrentUserId();
        testService.submitResults(userId, submission);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/log-view/{id}")
    public ResponseEntity<Void> logView(@PathVariable("id") Long id) {
        Long userId = getCurrentUserId();
        testService.logView(userId, id);
        return ResponseEntity.ok().build();
    }

    private Long getCurrentUserId() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof User) {
            return ((User) principal).getId();
        }
        
        throw new RuntimeException("User not authenticated");
    }
}
