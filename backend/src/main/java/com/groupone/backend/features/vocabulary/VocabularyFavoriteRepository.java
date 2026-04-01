package com.groupone.backend.features.vocabulary;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VocabularyFavoriteRepository extends JpaRepository<VocabularyFavoriteEntity, Long> {
    
    List<VocabularyFavoriteEntity> findAllByUserId(Long userId);
    
    Optional<VocabularyFavoriteEntity> findByUserIdAndVocabularyId(Long userId, Long vocabularyId);
    
    boolean existsByUserIdAndVocabularyId(Long userId, Long vocabularyId);

    void deleteByUserIdAndVocabularyId(Long userId, Long vocabularyId);
}
