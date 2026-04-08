package com.groupone.backend.features.feedback;

import com.groupone.backend.features.feedback.dto.FeedbackDetailDto;
import com.groupone.backend.features.feedback.dto.FeedbackDto;
import com.groupone.backend.features.feedback.dto.FeedbackReplyRequest;
import com.groupone.backend.features.identity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequiredArgsConstructor
@Slf4j
public class FeedbackController {

    private final FeedbackService feedbackService;

    // User endpoint to submit feedback
    @PostMapping("/api/user/feedback")
    public ResponseEntity<FeedbackDto> submitFeedback(
            @AuthenticationPrincipal User user,
            @RequestParam("title") String title,
            @RequestParam("textContent") String textContent,
            @RequestParam(value = "image", required = false) MultipartFile image) throws Exception {
        
        FeedbackDto savedFeedback = feedbackService.createFeedback(user.getId(), title, textContent, image);
        return ResponseEntity.ok(savedFeedback);
    }

    @GetMapping("/api/user/feedback")
    public ResponseEntity<Page<FeedbackDto>> getUserFeedbacks(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        return ResponseEntity.ok(feedbackService.getUserFeedbacks(user.getId(), pageable));
    }

    @GetMapping("/api/user/feedback/{id}")
    public ResponseEntity<FeedbackDetailDto> getUserFeedbackDetails(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        return ResponseEntity.ok(feedbackService.getUserFeedbackDetails(id, user.getId()));
    }

    // Admin endpoints
    @GetMapping("/api/admin/feedback")
    public ResponseEntity<Page<FeedbackDto>> getAllFeedbacks(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        return ResponseEntity.ok(feedbackService.getAllFeedbacks(pageable));
    }

    @GetMapping("/api/admin/feedback/{id}")
    public ResponseEntity<FeedbackDetailDto> getFeedbackDetails(@PathVariable Long id) {
        return ResponseEntity.ok(feedbackService.getFeedbackDetails(id));
    }

    @PostMapping("/api/admin/feedback/{id}/reply")
    public ResponseEntity<FeedbackDto> replyToFeedback(
            @AuthenticationPrincipal User adminUser,
            @PathVariable Long id,
            @RequestBody FeedbackReplyRequest request) {
        FeedbackDto updatedFeedback = feedbackService.replyToFeedback(id, adminUser.getId(), request.getTextContent());
        return ResponseEntity.ok(updatedFeedback);
    }
}
