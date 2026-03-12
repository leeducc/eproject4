package com.groupone.backend.features.quizbank.repository;

import com.groupone.backend.features.quizbank.entity.Exam;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ExamRepository extends JpaRepository<Exam, Long> {
}
