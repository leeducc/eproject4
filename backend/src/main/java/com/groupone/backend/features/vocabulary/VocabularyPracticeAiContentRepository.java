package com.groupone.backend.features.vocabulary;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface VocabularyPracticeAiContentRepository extends JpaRepository<VocabularyPracticeAiContentEntity, Long> {
    List<VocabularyPracticeAiContentEntity> findAllByWordAndQuizType(String word, String quizType);
    List<VocabularyPracticeAiContentEntity> findAllByWord(String word);
}
