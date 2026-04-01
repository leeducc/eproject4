package com.groupone.backend.features.smarttest.repository;

import com.groupone.backend.features.quizbank.enums.SkillType;
import com.groupone.backend.features.smarttest.entity.UserQuestionAttempt;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserQuestionAttemptRepository extends JpaRepository<UserQuestionAttempt, Long> {

    @Query("SELECT t.id FROM UserQuestionAttempt uqa " +
           "JOIN uqa.question q JOIN q.tags t " +
           "WHERE uqa.user.id = :userId AND uqa.isCorrect = false AND q.skill = :skill " +
           "GROUP BY t.id ORDER BY COUNT(uqa.id) DESC")
    List<Long> findWeakTagIdsByUserAndSkill(@Param("userId") Long userId, 
                                            @Param("skill") SkillType skill, 
                                            Pageable pageable);
}
