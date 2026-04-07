package com.groupone.backend.features.tutoring;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class TutoringReviewService {

    private final TutoringReviewRepository reviewRepository;
    private final TutoringSessionRepository sessionRepository;

    @Transactional
    public TutoringReview submitStudentReview(Long sessionId, Integer rating, String tags, String publicComment) {
        TutoringSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Session not found"));

        if (session.getStatus() != SessionStatus.COMPLETED) {
            throw new IllegalStateException("Review can only be submitted for completed sessions");
        }

        log.info("Student {} submitting review for Teacher {} on session {}", session.getStudent().getId(), session.getTeacher().getId(), sessionId);

        TutoringReview review = reviewRepository.findAllByStudentIdOrderByCreatedAtDesc(session.getStudent().getId())
                .stream().filter(r -> r.getSession().getId().equals(sessionId)).findFirst()
                .orElse(TutoringReview.builder()
                        .session(session)
                        .student(session.getStudent())
                        .teacher(session.getTeacher())
                        .build());
        
        review.setRating(rating);
        review.setTags(tags);
        review.setStudentReviewPublic(publicComment);
        
        return reviewRepository.save(review);
    }

    @Transactional
    public TutoringReview submitTeacherFeedback(Long sessionId, String privateFeedback) {
        TutoringSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Session not found"));

        if (session.getStatus() != SessionStatus.COMPLETED) {
            throw new IllegalStateException("Feedback can only be submitted for completed sessions");
        }

        log.info("Teacher {} submitting feedback for Student {} on session {}", session.getTeacher().getId(), session.getStudent().getId(), sessionId);

        TutoringReview review = reviewRepository.findAllByTeacherIdOrderByCreatedAtDesc(session.getTeacher().getId())
                .stream().filter(r -> r.getSession().getId().equals(sessionId)).findFirst()
                .orElse(TutoringReview.builder()
                        .session(session)
                        .student(session.getStudent())
                        .teacher(session.getTeacher())
                        .build());

        review.setTeacherFeedbackPrivate(privateFeedback);

        return reviewRepository.save(review);
    }
}
