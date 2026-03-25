package com.groupone.backend.features.quizbank.repository;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.quizbank.entity.ExamSubmission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExamSubmissionRepository extends JpaRepository<ExamSubmission, Long> {
    List<ExamSubmission> findByUserOrderByCreatedAtDesc(User user);
    List<ExamSubmission> findByUserAndExamIdOrderByCreatedAtDesc(User user, Long examId);
}
