package com.groupone.backend.features.quizbank.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.groupone.backend.features.quizbank.dto.QuestionRequest;
import com.groupone.backend.features.quizbank.dto.QuestionResponse;
import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.enums.SkillType;
import com.groupone.backend.features.quizbank.repository.QuestionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class QuestionBankService {

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private ObjectMapper objectMapper;

    public List<QuestionResponse> getAllQuestions(SkillType skill) {
        List<Question> questions = (skill != null) ? 
            questionRepository.findBySkill(skill) : 
            questionRepository.findAll();
            
        return questions.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    public QuestionResponse getQuestionById(Long id) {
        Question q = questionRepository.findById(id).orElseThrow(() -> new RuntimeException("Question not found"));
        return mapToResponse(q);
    }

    public QuestionResponse createQuestion(QuestionRequest req) {
        Question q = new Question();
        mapToEntity(req, q);
        Question saved = questionRepository.save(q);
        return mapToResponse(saved);
    }

    public QuestionResponse updateQuestion(Long id, QuestionRequest req) {
        Question q = questionRepository.findById(id).orElseThrow(() -> new RuntimeException("Question not found"));
        mapToEntity(req, q);
        Question saved = questionRepository.save(q);
        return mapToResponse(saved);
    }

    public void deleteQuestion(Long id) {
        questionRepository.deleteById(id);
    }

    private void mapToEntity(QuestionRequest req, Question q) {
        q.setSkill(req.getSkill());
        q.setType(req.getType());
        q.setDifficultyBand(req.getDifficultyBand());
        q.setIsPremiumContent(req.getIsPremiumContent());
        q.setInstruction(req.getInstruction());
        q.setExplanation(req.getExplanation());

        try {
            Map<String, Object> dataMap = req.getData() != null
                    ? new java.util.HashMap<>(req.getData())
                    : new java.util.HashMap<>();
            q.setData(objectMapper.writeValueAsString(dataMap));
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Error converting data to JSON", e);
        }
    }


    @SuppressWarnings("unchecked")
    public QuestionResponse mapToResponse(Question q) {
        Map<String, Object> dataMap = null;
        try {
            if (q.getData() != null) {
                dataMap = objectMapper.readValue(q.getData(), Map.class);
            }
        } catch (JsonProcessingException e) {
            // Ignore mapping error on read or log it
        }

        return QuestionResponse.builder()
                .id(q.getId())
                .skill(q.getSkill())
                .type(q.getType())
                .difficultyBand(q.getDifficultyBand())
                .data(dataMap)
                .isPremiumContent(q.getIsPremiumContent())
                .instruction(q.getInstruction())
                .explanation(q.getExplanation())
                .build();
    }
}
