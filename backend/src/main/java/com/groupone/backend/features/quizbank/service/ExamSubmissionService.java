package com.groupone.backend.features.quizbank.service;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.quizbank.dto.ExamSubmissionRequest;
import com.groupone.backend.features.quizbank.dto.ExamSubmissionResponse;
import com.groupone.backend.features.quizbank.entity.Exam;
import com.groupone.backend.features.quizbank.entity.ExamSubmission;
import com.groupone.backend.features.quizbank.enums.ExamSubmissionStatus;
import com.groupone.backend.features.quizbank.repository.ExamRepository;
import com.groupone.backend.features.quizbank.repository.ExamSubmissionRepository;
import com.groupone.backend.features.writing.WritingSubmission;
import com.groupone.backend.features.writing.WritingSubmissionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ExamSubmissionService {

    @Autowired
    private ExamSubmissionRepository examSubmissionRepository;

    @Autowired
    private ExamRepository examRepository;

    @Autowired
    private WritingSubmissionRepository writingSubmissionRepository;

    @Transactional
    public ExamSubmissionResponse submitExam(ExamSubmissionRequest request, User user) {
        Exam exam = examRepository.findById(request.getExamId())
                .orElseThrow(() -> new RuntimeException("Exam not found"));

        WritingSubmission writingSubmission = null;
        if (request.getWritingSubmissionId() != null) {
            writingSubmission = writingSubmissionRepository.findById(request.getWritingSubmissionId())
                    .orElse(null);
        }

        ExamSubmission submission = ExamSubmission.builder()
                .user(user)
                .exam(exam)
                .listeningScore(request.getListeningScore())
                .readingScore(request.getReadingScore())
                .writingSubmission(writingSubmission)
                .status(request.getStatus() != null ? request.getStatus() : ExamSubmissionStatus.IN_PROGRESS)
                .createdAt(LocalDateTime.now())
                .build();

        if (submission.getStatus() == ExamSubmissionStatus.COMPLETED) {
            submission.setCompletedAt(LocalDateTime.now());
        }

        ExamSubmission saved = examSubmissionRepository.save(submission);
        return mapToResponse(saved);
    }

    public List<ExamSubmissionResponse> getMySubmissions(User user) {
        return examSubmissionRepository.findByUserOrderByCreatedAtDesc(user).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private ExamSubmissionResponse mapToResponse(ExamSubmission submission) {
        Double writingScore = null;
        String writingStatus = null;

        if (submission.getWritingSubmission() != null) {
            writingScore = submission.getWritingSubmission().getScore();
            writingStatus = submission.getWritingSubmission().getStatus().name();
        }

        return ExamSubmissionResponse.builder()
                .id(submission.getId())
                .examId(submission.getExam().getId())
                .examTitle(submission.getExam().getTitle())
                .listeningScore(submission.getListeningScore())
                .readingScore(submission.getReadingScore())
                .writingScore(writingScore)
                .writingStatus(writingStatus)
                .status(submission.getStatus())
                .createdAt(submission.getCreatedAt())
                .completedAt(submission.getCompletedAt())
                .build();
    }
}
