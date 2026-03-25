package com.groupone.backend.features.writing;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.writing.dto.EssaySubmissionRequest;
import com.groupone.backend.features.writing.dto.EssaySubmissionResponse;
import com.groupone.backend.features.writing.dto.TopicResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/writing")
@RequiredArgsConstructor
public class WritingController {

    private final WritingService writingService;

    @GetMapping("/topics")
    public ResponseEntity<List<TopicResponse>> getTopics() {
        return ResponseEntity.ok(writingService.getAllTopics());
    }

    @PostMapping("/submit")
    public ResponseEntity<EssaySubmissionResponse> submitEssay(
            @RequestBody EssaySubmissionRequest request,
            @AuthenticationPrincipal User student) {
        return ResponseEntity.ok(writingService.submitEssay(request, student));
    }

    @GetMapping("/my-submissions")
    public ResponseEntity<List<EssaySubmissionResponse>> getMySubmissions(
            @AuthenticationPrincipal User student) {
        return ResponseEntity.ok(writingService.getStudentSubmissions(student));
    }

    @GetMapping("/submissions/{id}")
    public ResponseEntity<EssaySubmissionResponse> getSubmissionDetail(
            @PathVariable Long id,
            @AuthenticationPrincipal User student) {
        return ResponseEntity.ok(writingService.getSubmissionDetail(id, student));
    }
}
