package com.groupone.backend.controller;

import com.groupone.backend.dto.EssaySubmissionRequest;
import com.groupone.backend.dto.EssaySubmissionResponse;
import com.groupone.backend.dto.TopicDto;
import com.groupone.backend.service.WritingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/writing")
@RequiredArgsConstructor
public class WritingController {

    private final WritingService writingService;

    @GetMapping("/topics")
    public ResponseEntity<List<TopicDto>> getTopics() {
        return ResponseEntity.ok(writingService.getAllTopics());
    }

    @PostMapping("/submit")
    public ResponseEntity<EssaySubmissionResponse> submitEssay(@RequestBody EssaySubmissionRequest request) {
        // Here we could add user authentication validation
        return ResponseEntity.ok(writingService.submitEssay(request));
    }
}
