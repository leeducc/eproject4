package com.groupone.backend.features.ranking.repository;

import com.groupone.backend.features.ranking.entity.UserStats;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserStatsRepository extends JpaRepository<UserStats, Long> {

    Optional<UserStats> findByUserId(Long userId);

    

    @Query("""
        SELECT s FROM UserStats s
        JOIN FETCH s.user u
        LEFT JOIN FETCH u.profile p
        WHERE s.totalCorrectAnswers > 0
        ORDER BY s.totalCorrectAnswers DESC
    """)
    List<UserStats> findTopByCorrectAnswers(Pageable pageable);

    @Query("""
        SELECT s FROM UserStats s
        JOIN FETCH s.user u
        LEFT JOIN FETCH u.profile p
        WHERE s.totalVocabCorrect > 0
        ORDER BY s.totalVocabCorrect DESC
    """)
    List<UserStats> findTopByVocabCorrect(Pageable pageable);

    @Query("""
        SELECT s FROM UserStats s
        JOIN FETCH s.user u
        LEFT JOIN FETCH u.profile p
        WHERE s.totalTimeSeconds > 0
        ORDER BY s.totalTimeSeconds DESC
    """)
    List<UserStats> findTopByTimeSeconds(Pageable pageable);

    

    @Query("SELECT COUNT(s) + 1 FROM UserStats s WHERE s.totalCorrectAnswers > (SELECT ms.totalCorrectAnswers FROM UserStats ms WHERE ms.userId = :userId)")
    long findRankByAnswers(Long userId);

    @Query("SELECT COUNT(s) + 1 FROM UserStats s WHERE s.totalVocabCorrect > (SELECT ms.totalVocabCorrect FROM UserStats ms WHERE ms.userId = :userId)")
    long findRankByVocab(Long userId);

    @Query("SELECT COUNT(s) + 1 FROM UserStats s WHERE s.totalTimeSeconds > (SELECT ms.totalTimeSeconds FROM UserStats ms WHERE ms.userId = :userId)")
    long findRankByTime(Long userId);
}
