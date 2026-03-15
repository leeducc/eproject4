package com.groupone.backend.features.quizbank.repository;

import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.enums.DifficultyBand;
import com.groupone.backend.features.quizbank.enums.QuestionType;
import com.groupone.backend.features.quizbank.enums.SkillType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface QuestionRepository extends JpaRepository<Question, Long> {
    List<Question> findBySkill(SkillType skill);

    @org.springframework.data.jpa.repository.Query(value = 
        "SELECT * FROM qb_questions " +
        "WHERE (:skill IS NULL OR skill = :skill) " +
        "AND (:type IS NULL OR type = :type) " +
        "AND (:difficulty IS NULL OR difficulty_band = :difficulty) " +
        "AND (:lastSeenId IS NULL OR id > :lastSeenId) " +
        "AND (:search IS NULL OR MATCH(data, instruction, explanation) AGAINST(:search IN NATURAL LANGUAGE MODE)) " +
        "ORDER BY id ASC LIMIT :limit", 
        nativeQuery = true)
    List<Question> findPaginated(
            @org.springframework.data.repository.query.Param("skill") String skill, 
            @org.springframework.data.repository.query.Param("type") String type, 
            @org.springframework.data.repository.query.Param("difficulty") String difficulty, 
            @org.springframework.data.repository.query.Param("search") String search,
            @org.springframework.data.repository.query.Param("lastSeenId") Long lastSeenId, 
            @org.springframework.data.repository.query.Param("limit") int limit);
}
