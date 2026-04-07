package com.groupone.backend.features.tutoring;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/tutoring")
@RequiredArgsConstructor
public class TutoringController {

    private final TutoringSessionService sessionService;
    private final TutoringReviewService reviewService;
    private final UserRepository userRepository;
    private final TutoringSessionRepository sessionRepository;

    @PostMapping("/sessions/request")
    public ResponseEntity<TutoringSession> requestSession(
            @AuthenticationPrincipal User student,
            @RequestParam Long teacherId,
            @RequestParam int coinAmount) {
        
        User teacher = userRepository.findById(teacherId)
                .orElseThrow(() -> new RuntimeException("Teacher not found"));
        
        return ResponseEntity.ok(sessionService.requestSession(student, teacher, coinAmount));
    }

    @PostMapping("/sessions/{id}/start")
    public ResponseEntity<Void> startSession(@PathVariable Long id) {
        sessionService.startSession(id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/sessions/{id}/complete")
    public ResponseEntity<Void> completeSession(@PathVariable Long id) {
        sessionService.completeSession(id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/sessions/{id}/cancel")
    public ResponseEntity<Void> cancelSession(@PathVariable Long id, @RequestParam(required = false) String reason) {
        sessionService.cancelSession(id, reason);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/sessions/{id}/review/student")
    public ResponseEntity<TutoringReview> submitStudentReview(
            @PathVariable Long id,
            @RequestParam Integer rating,
            @RequestParam String tags,
            @RequestParam String publicComment) {
        return ResponseEntity.ok(reviewService.submitStudentReview(id, rating, tags, publicComment));
    }

    @PostMapping("/sessions/{id}/review/teacher")
    public ResponseEntity<TutoringReview> submitTeacherFeedback(
            @PathVariable Long id,
            @RequestParam String privateFeedback) {
        return ResponseEntity.ok(reviewService.submitTeacherFeedback(id, privateFeedback));
    }

    @GetMapping("/sessions/my")
    public ResponseEntity<List<TutoringSession>> getMySessions(@AuthenticationPrincipal User user) {
        if (user.getRole().name().equals("STUDENT")) {
            return ResponseEntity.ok(sessionRepository.findAllByStudentIdOrderByCreatedAtDesc(user.getId()));
        } else {
            return ResponseEntity.ok(sessionRepository.findAllByTeacherIdOrderByCreatedAtDesc(user.getId()));
        }
    }
}
