package com.groupone.backend.features.writing;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.quizbank.repository.QuestionRepository;
import com.groupone.backend.features.writing.dto.EssaySubmissionResponse;
import com.groupone.backend.features.writing.dto.GradingRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class WritingServiceTest {

    @Mock
    private WritingSubmissionRepository submissionRepository;

    @Mock
    private QuestionRepository questionRepository;

    @Mock
    private OllamaService ollamaService;

    @InjectMocks
    private WritingService writingService;

    private User teacher;
    private User otherTeacher;
    private WritingSubmission submission;
    private GradingRequest gradingRequest;

    @BeforeEach
    void setUp() {
        teacher = new User();
        teacher.setId(1L);
        teacher.setEmail("teacher@test.com");

        otherTeacher = new User();
        otherTeacher.setId(2L);
        otherTeacher.setEmail("other@test.com");

        submission = new WritingSubmission();
        submission.setId(1L);
        submission.setStatus(SubmissionStatus.IN_PROGRESS);
        submission.setLockedBy(teacher);

        gradingRequest = new GradingRequest();
        gradingRequest.setTaskAchievement(7.0);
        gradingRequest.setCohesionCoherence(7.5);
        gradingRequest.setLexicalResource(7.0);
        gradingRequest.setGrammaticalRange(6.5);
    }

    @Test
    void submitTeacherGrade_Success() {
        when(submissionRepository.findById(1L)).thenReturn(Optional.of(submission));
        when(submissionRepository.save(any(WritingSubmission.class))).thenAnswer(invocation -> invocation.getArgument(0));

        WritingSubmission result = writingService.submitTeacherGrade(1L, gradingRequest, teacher);

        assertNotNull(result);
        assertEquals(SubmissionStatus.GRADED, result.getStatus());
        assertEquals(7.0, result.getScore()); // (7+7.5+7+6.5)/4 = 7.0
        verify(submissionRepository).save(submission);
    }

    @Test
    void submitTeacherGrade_NotFound() {
        when(submissionRepository.findById(1L)).thenReturn(Optional.empty());

        Exception exception = assertThrows(RuntimeException.class, () -> 
            writingService.submitTeacherGrade(1L, gradingRequest, teacher)
        );

        assertEquals("Submission not found", exception.getMessage());
    }

    @Test
    void submitTeacherGrade_NotInProgress() {
        submission.setStatus(SubmissionStatus.PENDING);
        when(submissionRepository.findById(1L)).thenReturn(Optional.of(submission));

        Exception exception = assertThrows(RuntimeException.class, () -> 
            writingService.submitTeacherGrade(1L, gradingRequest, teacher)
        );

        assertEquals("Submission must be IN_PROGRESS to be graded", exception.getMessage());
    }

    @Test
    void submitTeacherGrade_LockedByNull() {
        submission.setLockedBy(null);
        when(submissionRepository.findById(1L)).thenReturn(Optional.of(submission));

        Exception exception = assertThrows(RuntimeException.class, () -> 
            writingService.submitTeacherGrade(1L, gradingRequest, teacher)
        );

        assertEquals("Submission is not locked by any teacher", exception.getMessage());
    }

    @Test
    void submitTeacherGrade_LockedByOtherTeacher() {
        submission.setLockedBy(otherTeacher);
        when(submissionRepository.findById(1L)).thenReturn(Optional.of(submission));

        Exception exception = assertThrows(RuntimeException.class, () -> 
            writingService.submitTeacherGrade(1L, gradingRequest, teacher)
        );

        assertEquals("You do not have the lock for this submission", exception.getMessage());
    }

    @Test
    void claimSubmission_Graded_ReturnsSubmission() {
        submission.setStatus(SubmissionStatus.GRADED);
        when(submissionRepository.findById(1L)).thenReturn(Optional.of(submission));

        WritingSubmission result = writingService.claimSubmission(1L, teacher);

        assertNotNull(result);
        assertEquals(SubmissionStatus.GRADED, result.getStatus());
        verify(submissionRepository, never()).save(any());
    }

    @Test
    void getStudentSubmissions_ReturnsList() {
        when(submissionRepository.findByStudentOrderByCreatedAtDesc(teacher)).thenReturn(java.util.List.of(submission));

        java.util.List<EssaySubmissionResponse> result = writingService.getStudentSubmissions(teacher);

        assertNotNull(result);
        assertEquals(1, result.size());
        verify(submissionRepository).findByStudentOrderByCreatedAtDesc(teacher);
    }

    @Test
    void getSubmissionDetail_Success() {
        submission.setStudent(teacher);
        when(submissionRepository.findById(1L)).thenReturn(Optional.of(submission));

        EssaySubmissionResponse result = writingService.getSubmissionDetail(1L, teacher);

        assertNotNull(result);
        assertEquals(submission.getId(), result.getId());
    }

    @Test
    void getSubmissionDetail_NoPermission() {
        submission.setStudent(otherTeacher);
        when(submissionRepository.findById(1L)).thenReturn(Optional.of(submission));

        Exception exception = assertThrows(RuntimeException.class, () -> 
            writingService.getSubmissionDetail(1L, teacher)
        );

        assertEquals("You do not have permission to view this submission", exception.getMessage());
    }
}
