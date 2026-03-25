package com.groupone.backend.features.quizbank.repository;

import com.groupone.backend.features.quizbank.entity.Exam;
import com.groupone.backend.features.quizbank.enums.ExamType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExamRepository extends JpaRepository<Exam, Long> {
    List<Exam> findByExamType(ExamType examType);
}
