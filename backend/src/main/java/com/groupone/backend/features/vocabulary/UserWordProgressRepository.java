package com.groupone.backend.features.vocabulary;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserWordProgressRepository extends JpaRepository<UserWordProgress, Long> {
    
    Optional<UserWordProgress> findByUserIdAndVocabularyId(Long userId, Long vocabularyId);
    
    @Query("SELECT uwp FROM UserWordProgress uwp WHERE uwp.user.id = :userId AND uwp.nextReviewDate <= :now")
    List<UserWordProgress> findDueForReview(@Param("userId") Long userId, @Param("now") LocalDateTime now);
    
    @Query("SELECT uwp FROM UserWordProgress uwp WHERE uwp.user.id = :userId AND uwp.proficiencyLevel < 3 AND uwp.isViewed = true")
    List<UserWordProgress> findWeakWords(@Param("userId") Long userId);

    @Query("SELECT uwp FROM UserWordProgress uwp WHERE uwp.user.id = :userId AND uwp.isViewed = true AND uwp.proficiencyLevel = 0")
    List<UserWordProgress> findViewedButNotTested(@Param("userId") Long userId);

    @Query(value = "SELECT v.id FROM vocabulary v WHERE v.id NOT IN (SELECT uwp.vocabulary_id FROM user_word_progress uwp WHERE uwp.user_id = :userId) ORDER BY RAND() LIMIT :limit", nativeQuery = true)
    List<Long> findNewWordIds(@Param("userId") Long userId, @Param("limit") int limit);
}
