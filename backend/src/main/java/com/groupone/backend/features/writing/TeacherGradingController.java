package com.groupone.backend.features.writing;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.features.writing.dto.GradingRequest;
import com.groupone.backend.features.writing.dto.SubmissionSummaryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/teacher/grading")
@RequiredArgsConstructor
public class TeacherGradingController {

    private final WritingService writingService;
    private final UserRepository userRepository;

    @GetMapping("/submissions")
    public ResponseEntity<List<SubmissionSummaryResponse>> getAllSubmissions() {
        return ResponseEntity.ok(
            writingService.getAllSubmissions().stream()
                .map(SubmissionSummaryResponse::fromEntity)
                .collect(Collectors.toList())
        );
    }

    @PostMapping("/submissions/{id}/claim")
    public ResponseEntity<SubmissionSummaryResponse> claimSubmission(
            @PathVariable Long id,
            @AuthenticationPrincipal User teacher) {
        
        return ResponseEntity.ok(
            SubmissionSummaryResponse.fromEntity(writingService.claimSubmission(id, teacher))
        );
    }

    @PostMapping("/submissions/{id}/unclaim")
    public ResponseEntity<SubmissionSummaryResponse> unclaimSubmission(
            @PathVariable Long id,
            @AuthenticationPrincipal User teacher) {
        
        return ResponseEntity.ok(
            SubmissionSummaryResponse.fromEntity(writingService.unclaimSubmission(id, teacher))
        );
    }

    @PostMapping("/submissions/{id}/grade")
    public ResponseEntity<SubmissionSummaryResponse> submitGrade(
            @PathVariable Long id,
            @RequestBody GradingRequest request,
            @AuthenticationPrincipal User teacher) {
            
        return ResponseEntity.ok(
            SubmissionSummaryResponse.fromEntity(writingService.submitTeacherGrade(id, request, teacher))
        );
    }
}
