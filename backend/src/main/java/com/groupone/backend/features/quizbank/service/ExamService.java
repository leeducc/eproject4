package com.groupone.backend.features.quizbank.service;
import org.springframework.transaction.annotation.Transactional;

import com.groupone.backend.features.quizbank.dto.ExamRequest;
import com.groupone.backend.features.quizbank.dto.ExamResponse;
import com.groupone.backend.features.quizbank.dto.QuestionResponse;
import com.groupone.backend.features.quizbank.dto.QuestionGroupResponse;
import com.groupone.backend.features.quizbank.entity.Exam;
import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.entity.QuestionGroup;
import com.groupone.backend.features.quizbank.enums.ExamType;
import com.groupone.backend.features.quizbank.enums.SkillType;
import com.groupone.backend.features.quizbank.repository.ExamRepository;
import com.groupone.backend.features.quizbank.repository.QuestionRepository;
import com.groupone.backend.features.quizbank.repository.QuestionGroupRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;
import java.util.HashSet;
import java.util.stream.Collectors;

@Service
public class ExamService {

    @Autowired
    private ExamRepository examRepository;

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private QuestionGroupRepository questionGroupRepository;

    @Autowired
    private QuestionBankService questionBankService;

    @Transactional(readOnly = true)
    public List<ExamResponse> getAllExams() {
        return examRepository.findAll().stream().map(this::mapToResponseDTO).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ExamResponse> getExamsByType(ExamType examType) {
        return examRepository.findByExamType(examType).stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public ExamResponse getExamById(Long id) {
        Exam e = examRepository.findById(id).orElseThrow(() -> new RuntimeException("Exam not found"));
        return mapToResponseDTO(e);
    }

    public ExamResponse createExam(ExamRequest req) {
        if (req.getExamType() == ExamType.IELTS) {
            validateIELTSExam(req);
        }

        Exam e = new Exam();
        e.setTitle(req.getTitle());
        e.setExamType(req.getExamType());
        e.setDescription(req.getDescription());
        e.setDifficultyBand(req.getDifficultyBand());
        
        if (req.getQuestionIds() != null && !req.getQuestionIds().isEmpty()) {
            List<Question> questions = questionRepository.findAllById(req.getQuestionIds());
            e.setQuestions(questions);
        }

        if (req.getGroupIds() != null && !req.getGroupIds().isEmpty()) {
            List<QuestionGroup> groups = questionGroupRepository.findAllById(req.getGroupIds());
            e.setGroups(groups);
        }

        Exam saved = examRepository.save(e);
        return mapToResponseDTO(saved);
    }

    public ExamResponse updateExam(Long id, ExamRequest req) {
        if (req.getExamType() == ExamType.IELTS) {
            validateIELTSExam(req);
        }

        Exam e = examRepository.findById(id).orElseThrow(() -> new RuntimeException("Exam not found"));
        e.setTitle(req.getTitle());
        e.setExamType(req.getExamType());
        e.setDescription(req.getDescription());
        e.setDifficultyBand(req.getDifficultyBand());
        
        if (req.getQuestionIds() != null) {
            List<Question> questions = questionRepository.findAllById(req.getQuestionIds());
            e.setQuestions(questions);
        } else {
            e.getQuestions().clear();
        }

        if (req.getGroupIds() != null) {
            List<QuestionGroup> groups = questionGroupRepository.findAllById(req.getGroupIds());
            e.setGroups(groups);
        } else {
            e.getGroups().clear();
        }

        Exam saved = examRepository.save(e);
        return mapToResponseDTO(saved);
    }

    private void validateIELTSExam(ExamRequest req) {
        int listeningCount = 0;
        int readingCount = 0;
        int writingCount = 0;

        if (req.getGroupIds() != null) {
            List<QuestionGroup> groups = questionGroupRepository.findAllById(req.getGroupIds());
            for (QuestionGroup g : groups) {
                if (g.getSkill() == SkillType.LISTENING) listeningCount++;
                if (g.getSkill() == SkillType.READING) readingCount++;
            }
        }

        if (req.getQuestionIds() != null) {
            List<Question> questions = questionRepository.findAllById(req.getQuestionIds());
            for (Question q : questions) {
                if (q.getSkill() == SkillType.WRITING) writingCount++;
            }
        }

        if (listeningCount != 4 || readingCount != 3 || writingCount != 2) {
            throw new RuntimeException(String.format(
                "IELTS Exam must have exactly 4 Listening passages (found %d), 3 Reading passages (found %d), and 2 Writing tasks (found %d).",
                listeningCount, readingCount, writingCount
            ));
        }
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

        List<QuestionGroupResponse> grs = null;
        if (e.getGroups() != null) {
            grs = e.getGroups().stream()
                .map(g -> {
                    QuestionResponse qr = questionBankService.mapGroupToResponse(g);
                    return QuestionGroupResponse.builder()
                            .id(qr.getId())
                            .skill(qr.getSkill())
                            .difficultyBand(qr.getDifficultyBand())
                            .title(qr.getInstruction())
                            .content((String) qr.getData().get("content"))
                            .mediaUrl(qr.getMediaUrls() != null && !qr.getMediaUrls().isEmpty() ? qr.getMediaUrls().get(0) : null)
                            .mediaType(qr.getMediaTypes() != null && !qr.getMediaTypes().isEmpty() ? qr.getMediaTypes().get(0) : null)
                            .questions((List<QuestionResponse>) qr.getData().get("questions"))
                            .build();
                })
                .collect(Collectors.toList());
        }

        List<Long> qIds = e.getQuestions() != null 
            ? e.getQuestions().stream().map(Question::getId).collect(Collectors.toList())
            : List.of();
        
        List<Long> gIds = e.getGroups() != null
            ? e.getGroups().stream().map(QuestionGroup::getId).collect(Collectors.toList())
            : List.of();

        Set<String> categorySet = new java.util.HashSet<>();
        if (e.getQuestions() != null) {
            e.getQuestions().forEach(q -> categorySet.add(q.getSkill().name()));
        }
        if (e.getGroups() != null) {
            e.getGroups().forEach(g -> categorySet.add(g.getSkill().name()));
        }

        return ExamResponse.builder()
                .id(e.getId())
                .title(e.getTitle())
                .examType(e.getExamType())
                .description(e.getDescription())
                .difficultyBand(e.getDifficultyBand())
                .createdAt(e.getCreatedAt())
                .questionIds(qIds)
                .groupIds(gIds)
                .categories(new java.util.ArrayList<>(categorySet))
                .questions(qrs)
                .groups(grs)
                .build();
    }
}
