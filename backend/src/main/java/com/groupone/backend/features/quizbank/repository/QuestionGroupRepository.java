package com.groupone.backend.features.quizbank.repository;

import com.groupone.backend.features.quizbank.entity.QuestionGroup;
import com.groupone.backend.features.quizbank.enums.SkillType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestionGroupRepository extends JpaRepository<QuestionGroup, Long> {
    List<QuestionGroup> findBySkill(SkillType skill);
}
