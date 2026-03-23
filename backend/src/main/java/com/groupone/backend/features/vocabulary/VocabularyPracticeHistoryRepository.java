package com.groupone.backend.features.vocabulary;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface VocabularyPracticeHistoryRepository extends JpaRepository<VocabularyPracticeHistory, Long> {
    @Query("SELECT new com.groupone.backend.features.vocabulary.VocabularyPracticeHistoryDTO(" +
           "h.id, h.practiceId, h.editorId, p.fullName, h.action, h.snapshot, h.version, h.createdAt) " +
           "FROM VocabularyPracticeHistory h " +
           "LEFT JOIN User u ON h.editorId = u.id " +
           "LEFT JOIN UserProfile p ON u.id = p.id " +
           "WHERE h.practiceId = :practiceId " +
           "ORDER BY h.createdAt DESC")
    List<VocabularyPracticeHistoryDTO> findHistoryWithEditorName(@Param("practiceId") Long practiceId);

    List<VocabularyPracticeHistory> findByPracticeIdOrderByCreatedAtDesc(Long practiceId);
    Page<VocabularyPracticeHistory> findByPracticeIdOrderByCreatedAtDesc(Long practiceId, Pageable pageable);
}
