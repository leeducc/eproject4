package com.groupone.backend.features.quizbank.repository;

import com.groupone.backend.features.quizbank.entity.QuestionHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import java.util.List;

@Repository
public interface QuestionHistoryRepository extends JpaRepository<QuestionHistory, Long> {
    List<QuestionHistory> findByQuestionIdOrderByCreatedAtDesc(Long questionId);
    Page<QuestionHistory> findByQuestionIdOrderByCreatedAtDesc(Long questionId, Pageable pageable);
}
