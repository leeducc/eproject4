package com.groupone.backend.features.quizbank.repository;

import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.enums.DifficultyBand;
import com.groupone.backend.features.quizbank.enums.QuestionType;
import com.groupone.backend.features.quizbank.enums.SkillType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

@Repository
public interface QuestionRepository extends JpaRepository<Question, Long>, JpaSpecificationExecutor<Question> {
    List<Question> findBySkill(SkillType skill);

    List<Question> findBySkillAndType(SkillType skill, QuestionType type);

    @org.springframework.data.jpa.repository.Query(value = "SELECT * FROM qb_questions q JOIN qb_question_tags qt ON q.id = qt.question_id WHERE q.skill = :skill AND q.difficulty_band = :difficulty AND qt.tag_id IN :tagIds ORDER BY RAND() LIMIT :limit", nativeQuery = true)
    List<Question> findRandomBySkillAndDifficultyAndTags(
            @org.springframework.data.repository.query.Param("skill") String skill,
            @org.springframework.data.repository.query.Param("difficulty") String difficulty,
            @org.springframework.data.repository.query.Param("tagIds") List<Long> tagIds,
            @org.springframework.data.repository.query.Param("limit") int limit);

    @org.springframework.data.jpa.repository.Query(value = "SELECT * FROM qb_questions q JOIN qb_question_tags qt ON q.id = qt.question_id " +
            "WHERE q.skill = :skill AND q.difficulty_band = :difficulty " +
            "AND qt.tag_id IN :tagIds " +
            "AND (:excludeIds IS NULL OR q.id NOT IN :excludeIds) " +
            "ORDER BY RAND() LIMIT :limit", nativeQuery = true)
    List<Question> findRandomBySkillAndDifficultyAndTagsExcluding(
            @org.springframework.data.repository.query.Param("skill") String skill,
            @org.springframework.data.repository.query.Param("difficulty") String difficulty,
            @org.springframework.data.repository.query.Param("tagIds") List<Long> tagIds,
            @org.springframework.data.repository.query.Param("excludeIds") List<Long> excludeIds,
            @org.springframework.data.repository.query.Param("limit") int limit);

    @org.springframework.data.jpa.repository.Query(value = "SELECT * FROM qb_questions WHERE skill = :skill AND difficulty_band = :difficulty ORDER BY RAND() LIMIT :limit", nativeQuery = true)
    List<Question> findRandomBySkillAndDifficulty(
            @org.springframework.data.repository.query.Param("skill") String skill,
            @org.springframework.data.repository.query.Param("difficulty") String difficulty,
            @org.springframework.data.repository.query.Param("limit") int limit);

    @org.springframework.data.jpa.repository.Query(value = "SELECT * FROM qb_questions " +
            "WHERE skill = :skill AND difficulty_band = :difficulty " +
            "AND (:excludeIds IS NULL OR id NOT IN :excludeIds) " +
            "ORDER BY RAND() LIMIT :limit", nativeQuery = true)
    List<Question> findRandomBySkillAndDifficultyExcluding(
            @org.springframework.data.repository.query.Param("skill") String skill,
            @org.springframework.data.repository.query.Param("difficulty") String difficulty,
            @org.springframework.data.repository.query.Param("excludeIds") List<Long> excludeIds,
            @org.springframework.data.repository.query.Param("limit") int limit);


    @org.springframework.data.jpa.repository.Query(value = 
        "SELECT * FROM qb_questions " +
        "WHERE (:skill IS NULL OR skill = :skill) " +
        "AND (:type IS NULL OR type = :type) " +
        "AND (:difficulty IS NULL OR difficulty_band = :difficulty) " +
        "AND (:lastSeenId IS NULL OR id > :lastSeenId) " +
        "AND (:authorId IS NULL OR author_id = :authorId) " +
        "AND (group_id IS NULL) " +
        "AND (:search IS NULL OR MATCH(data, instruction, explanation) AGAINST(:search IN NATURAL LANGUAGE MODE)) " +
        "ORDER BY id ASC LIMIT :limit", 
        nativeQuery = true)
    List<Question> findPaginated(
            @org.springframework.data.repository.query.Param("skill") String skill, 
            @org.springframework.data.repository.query.Param("type") String type, 
            @org.springframework.data.repository.query.Param("difficulty") String difficulty, 
            @org.springframework.data.repository.query.Param("search") String search,
            @org.springframework.data.repository.query.Param("lastSeenId") Long lastSeenId, 
            @org.springframework.data.repository.query.Param("authorId") Long authorId,
            @org.springframework.data.repository.query.Param("limit") int limit);
}
