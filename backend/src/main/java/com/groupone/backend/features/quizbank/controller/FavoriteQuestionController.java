package com.groupone.backend.features.quizbank.controller;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.quizbank.service.FavoriteQuestionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/questions/favorite")
public class FavoriteQuestionController {

    @Autowired
    private FavoriteQuestionService favoriteQuestionService;

    @GetMapping
    public ResponseEntity<java.util.List<com.groupone.backend.features.quizbank.dto.QuestionResponse>> getFavorites(
            @AuthenticationPrincipal User user) {
        
        if (user == null) {
            return ResponseEntity.status(401).build();
        }

        return ResponseEntity.ok(favoriteQuestionService.getFavoriteQuestions(user));
    }

    @PostMapping("/{questionId}")
    public ResponseEntity<Map<String, Object>> toggleFavorite(
            @AuthenticationPrincipal User user,
            @PathVariable Long questionId) {
        
        if (user == null) {
            return ResponseEntity.status(401).build();
        }

        boolean isFavorite = favoriteQuestionService.toggleFavorite(user, questionId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("questionId", questionId);
        response.put("isFavorite", isFavorite);
        response.put("message", isFavorite ? "Question saved to favorites" : "Question removed from favorites");
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{questionId}/status")
    public ResponseEntity<Map<String, Object>> getFavoriteStatus(
            @AuthenticationPrincipal User user,
            @PathVariable Long questionId) {
        
        if (user == null) {
            return ResponseEntity.status(401).build();
        }

        boolean isFavorite = favoriteQuestionService.isFavorite(user, questionId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("questionId", questionId);
        response.put("isFavorite", isFavorite);
        
        return ResponseEntity.ok(response);
    }
}
