package com.groupone.backend.features.quizbank.repository;

import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.enums.SkillType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface QuestionRepository extends JpaRepository<Question, Long> {
    List<Question> findBySkill(SkillType skill);
}
