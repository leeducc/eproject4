package com.groupone.backend.features.quizbank.service;

import com.groupone.backend.features.quizbank.dto.ExamRequest;
import com.groupone.backend.features.quizbank.dto.ExamResponse;
import com.groupone.backend.features.quizbank.dto.QuestionResponse;
import com.groupone.backend.features.quizbank.entity.Exam;
import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.repository.ExamRepository;
import com.groupone.backend.features.quizbank.repository.QuestionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ExamService {

    @Autowired
    private ExamRepository examRepository;

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private QuestionBankService questionBankService;

    public List<ExamResponse> getAllExams() {
        return examRepository.findAll().stream().map(this::mapToResponseDTO).collect(Collectors.toList());
    }

    public ExamResponse getExamById(Long id) {
        Exam e = examRepository.findById(id).orElseThrow(() -> new RuntimeException("Exam not found"));
        return mapToResponseDTO(e);
    }

    public ExamResponse createExam(ExamRequest req) {
        Exam e = new Exam();
        e.setTitle(req.getTitle());
        e.setExamType(req.getExamType());
        e.setDescription(req.getDescription());
        if (req.getQuestionIds() != null && !req.getQuestionIds().isEmpty()) {
            List<Question> questions = questionRepository.findAllById(req.getQuestionIds());
            e.setQuestions(questions);
        }
        Exam saved = examRepository.save(e);
        return mapToResponseDTO(saved);
    }

    public ExamResponse updateExam(Long id, ExamRequest req) {
        Exam e = examRepository.findById(id).orElseThrow(() -> new RuntimeException("Exam not found"));
        e.setTitle(req.getTitle());
        e.setExamType(req.getExamType());
        e.setDescription(req.getDescription());
        if (req.getQuestionIds() != null) {
            List<Question> questions = questionRepository.findAllById(req.getQuestionIds());
            e.setQuestions(questions);
        }
        Exam saved = examRepository.save(e);
        return mapToResponseDTO(saved);
    }

    public void deleteExam(Long id) {
        examRepository.deleteById(id);
    }

    private ExamResponse mapToResponseDTO(Exam e) {
        List<QuestionResponse> qrs = null;
        if (e.getQuestions() != null) {
            qrs = e.getQuestions().stream()
                .map(q -> questionBankService.mapToResponse(q))
                .collect(Collectors.toList());
        }

        return ExamResponse.builder()
                .id(e.getId())
                .title(e.getTitle())
                .examType(e.getExamType())
                .description(e.getDescription())
                .createdAt(e.getCreatedAt())
                .questions(qrs)
                .build();
    }
}
