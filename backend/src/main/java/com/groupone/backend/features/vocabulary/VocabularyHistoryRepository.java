package com.groupone.backend.features.vocabulary;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface VocabularyHistoryRepository extends JpaRepository<VocabularyHistory, Long> {
    @Query("SELECT new com.groupone.backend.features.vocabulary.VocabularyHistoryDTO(" +
           "h.id, h.vocabularyId, h.editorId, p.fullName, h.action, h.snapshot, h.changes, h.createdAt) " +
           "FROM VocabularyHistory h " +
           "LEFT JOIN User u ON h.editorId = u.id " +
           "LEFT JOIN UserProfile p ON u.id = p.id " +
           "WHERE h.vocabularyId = :vocabularyId " +
           "ORDER BY h.createdAt DESC")
    List<VocabularyHistoryDTO> findHistoryWithEditorName(@Param("vocabularyId") Long vocabularyId);

    List<VocabularyHistory> findByVocabularyIdOrderByCreatedAtDesc(Long vocabularyId);
    Page<VocabularyHistory> findByVocabularyIdOrderByCreatedAtDesc(Long vocabularyId, Pageable pageable);
}
