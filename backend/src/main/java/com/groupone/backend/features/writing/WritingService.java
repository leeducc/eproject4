package com.groupone.backend.features.writing;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.enums.QuestionType;
import com.groupone.backend.features.quizbank.enums.SkillType;
import com.groupone.backend.features.quizbank.repository.QuestionRepository;
import com.groupone.backend.features.writing.dto.EssaySubmissionRequest;
import com.groupone.backend.features.writing.dto.EssaySubmissionResponse;
import com.groupone.backend.features.writing.dto.GradingRequest;
import com.groupone.backend.features.writing.dto.TopicResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class WritingService {

    private final QuestionRepository questionRepository;
    private final WritingSubmissionRepository submissionRepository;
    private final OllamaService ollamaService;

    public List<TopicResponse> getAllTopics() {
        log.info("Fetching all writing tasks from Quiz Bank");
        return questionRepository.findBySkillAndType(SkillType.WRITING, QuestionType.ESSAY).stream()
                .map(TopicResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<WritingSubmission> getAllSubmissions() {
        return submissionRepository.findAll();
    }

    @Transactional
    public WritingSubmission claimSubmission(Long id, User teacher) {
        WritingSubmission submission = submissionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Submission not found"));

        if (submission.getStatus() != SubmissionStatus.PENDING) {
            // Allow re-claiming if the current user is the locker
            if (submission.getStatus() == SubmissionStatus.IN_PROGRESS && 
                submission.getLockedBy() != null && 
                submission.getLockedBy().getId().equals(teacher.getId())) {
                log.info("Teacher {} is re-claiming their own locked submission {}", teacher.getEmail(), id);
                return submission;
            }
            throw new RuntimeException("Submission is already claimed or graded");
        }

        submission.setStatus(SubmissionStatus.IN_PROGRESS);
        submission.setLockedBy(teacher);
        submission.setLockedAt(LocalDateTime.now());
        
        return submissionRepository.save(submission);
    }

    @Transactional
    public WritingSubmission unclaimSubmission(Long id, User teacher) {
        WritingSubmission submission = submissionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Submission not found"));

        if (submission.getStatus() != SubmissionStatus.IN_PROGRESS) {
            throw new RuntimeException("Only IN_PROGRESS submissions can be unclaimed");
        }

        if (submission.getLockedBy() == null || !submission.getLockedBy().getId().equals(teacher.getId())) {
            throw new RuntimeException("You do not have the lock for this submission");
        }

        submission.setStatus(SubmissionStatus.PENDING);
        submission.setLockedBy(null);
        submission.setLockedAt(null);
        
        log.info("Teacher {} unclaimed submission {}", teacher.getEmail(), id);
        return submissionRepository.save(submission);
    }

    @Transactional
    public WritingSubmission submitTeacherGrade(Long id, GradingRequest request, User teacher) {
        WritingSubmission submission = submissionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Submission not found"));

        if (!submission.getLockedBy().getId().equals(teacher.getId())) {
            throw new RuntimeException("You do not have the lock for this submission");
        }

        submission.setTaskAchievement(request.getTaskAchievement());
        submission.setCohesionCoherence(request.getCohesionCoherence());
        submission.setLexicalResource(request.getLexicalResource());
        submission.setGrammaticalRange(request.getGrammaticalRange());
        submission.setTeacherFeedback(request.getTeacherFeedback());
        
        // Detailed Reasoning & Corrections
        submission.setTaskAchievementReason(request.getTaskAchievementReason());
        submission.setCohesionCoherenceReason(request.getCohesionCoherenceReason());
        submission.setLexicalResourceReason(request.getLexicalResourceReason());
        submission.setGrammaticalRangeReason(request.getGrammaticalRangeReason());
        submission.setCorrectionsJson(request.getCorrectionsJson());
        
        // Calculate average score
        double avg = (request.getTaskAchievement() + request.getCohesionCoherence() + 
                     request.getLexicalResource() + request.getGrammaticalRange()) / 4.0;
        submission.setScore(Math.round(avg * 2) / 2.0); // Round to nearest 0.5
        
        submission.setStatus(SubmissionStatus.GRADED);
        
        return submissionRepository.save(submission);
    }

    public EssaySubmissionResponse submitEssay(EssaySubmissionRequest request, User student) {
        try {
            if (student == null) {
                log.error("Submission failed: Authenticated student user is null");
                throw new RuntimeException("User not authenticated");
            }
            
            log.info("Submitting essay for questionId {} by student {}", request.getTopicId(), student.getEmail());
            
            Question question = questionRepository.findById(request.getTopicId())
                    .orElseThrow(() -> {
                        log.error("Submission failed: Question with ID {} not found", request.getTopicId());
                        return new RuntimeException("Question not found");
                    });
                    
            // Initialize submission
            WritingSubmission submission = WritingSubmission.builder()
                    .question(question)
                    .student(student)
                    .content(request.getContent())
                    .gradingType(request.getGradingType())
                    .createdAt(LocalDateTime.now())
                    .status(SubmissionStatus.PENDING)
                    .build();

            // Perform AI Grading if requested
            if (request.getGradingType() == GradingType.AI) {
                log.info("Initiating AI Grading for submission on question '{}'", question.getInstruction());
                OllamaService.OllamaGradingResult result = ollamaService.gradeEssay(question.getInstruction(), request.getContent());
                submission.setScore(result.score());
                submission.setAiFeedback(result.feedback());
                submission.setStatus(SubmissionStatus.GRADED);
            }
                    
            WritingSubmission savedSubmission = submissionRepository.save(submission);
            log.info("Successfully saved essay submission with ID {}", savedSubmission.getId());
            
            return EssaySubmissionResponse.fromEntity(savedSubmission);
        } catch (Exception e) {
            log.error("Critical error during essay submission: {}", e.getMessage(), e);
            throw e;
        }
    }
}
