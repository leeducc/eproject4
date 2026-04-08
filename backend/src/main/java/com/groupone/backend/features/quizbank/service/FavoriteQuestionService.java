package com.groupone.backend.features.quizbank.service;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.quizbank.entity.FavoriteQuestionEntity;
import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.repository.FavoriteQuestionRepository;
import com.groupone.backend.features.quizbank.repository.QuestionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
public class FavoriteQuestionService {

    @Autowired
    private FavoriteQuestionRepository favoriteQuestionRepository;

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private QuestionBankService questionBankService;

    public java.util.List<com.groupone.backend.features.quizbank.dto.QuestionResponse> getFavoriteQuestions(User user) {
        return favoriteQuestionRepository.findByUser(user).stream()
                .map(favorite -> questionBankService.mapToResponse(favorite.getQuestion()))
                .collect(java.util.stream.Collectors.toList());
    }

    @Transactional
    public boolean toggleFavorite(User user, Long questionId) {
        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new RuntimeException("Question not found"));

        Optional<FavoriteQuestionEntity> existing = favoriteQuestionRepository.findByUserAndQuestion(user, question);

        if (existing.isPresent()) {
            favoriteQuestionRepository.delete(existing.get());
            return false; // Result: Not favorite
        } else {
            FavoriteQuestionEntity favorite = FavoriteQuestionEntity.builder()
                    .user(user)
                    .question(question)
                    .build();
            favoriteQuestionRepository.save(favorite);
            return true; // Result: Is favorite
        }
    }

    public boolean isFavorite(User user, Long questionId) {
        return questionRepository.findById(questionId)
                .map(question -> favoriteQuestionRepository.existsByUserAndQuestion(user, question))
                .orElse(false);
    }
}
