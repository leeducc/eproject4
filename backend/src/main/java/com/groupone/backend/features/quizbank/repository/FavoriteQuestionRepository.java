package com.groupone.backend.features.quizbank.repository;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.quizbank.entity.FavoriteQuestionEntity;
import com.groupone.backend.features.quizbank.entity.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavoriteQuestionRepository extends JpaRepository<FavoriteQuestionEntity, Long> {
    Optional<FavoriteQuestionEntity> findByUserAndQuestion(User user, Question question);
    List<FavoriteQuestionEntity> findByUser(User user);
    boolean existsByUserAndQuestion(User user, Question question);
}
