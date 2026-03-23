package com.groupone.backend.features.quizbank.service;

import com.groupone.backend.features.quizbank.dto.*;
import com.groupone.backend.features.quizbank.entity.*;
import com.groupone.backend.features.quizbank.enums.SkillType;
import com.groupone.backend.features.quizbank.repository.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j
public class QuestionGroupService {

    @Autowired
    private QuestionGroupRepository questionGroupRepository;

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private QuestionBankService questionBankService;

    public List<QuestionGroupResponse> getAllGroups(SkillType skill) {
        List<QuestionGroup> groups = (skill != null) 
                ? questionGroupRepository.findBySkill(skill)
                : questionGroupRepository.findAll();
        
        return groups.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    public QuestionGroupResponse getGroupById(Long id) {
        QuestionGroup group = questionGroupRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Question group not found"));
        return mapToResponse(group);
    }

    @Transactional
    public QuestionGroupResponse createGroup(QuestionGroupRequest req) {
        QuestionGroup group = new QuestionGroup();
        mapToEntity(req, group);
        QuestionGroup savedGroup = questionGroupRepository.save(group);
        
        if (req.getQuestions() != null) {
            for (QuestionRequest qReq : req.getQuestions()) {
                questionBankService.createQuestion(qReq, null); // Media handled separately or in chunks
                // Note: We need to link the created question to the group.
                // QuestionBankService might need an update to accept group_id or we link it here.
            }
        }
        
        return mapToResponse(savedGroup);
    }

    @Transactional
    public QuestionGroupResponse updateGroup(Long id, QuestionGroupRequest req) {
        QuestionGroup group = questionGroupRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Question group not found"));
        mapToEntity(req, group);
        QuestionGroup saved = questionGroupRepository.save(group);
        return mapToResponse(saved);
    }

    @Transactional
    public void deleteGroup(Long id) {
        questionGroupRepository.deleteById(id);
    }

    private void mapToEntity(QuestionGroupRequest req, QuestionGroup group) {
        group.setSkill(req.getSkill());
        group.setTitle(req.getTitle());
        group.setContent(req.getContent());
        group.setMediaUrl(req.getMediaUrl());
        group.setMediaType(req.getMediaType());
        group.setDifficultyBand(req.getDifficultyBand());
        group.setAuthorId(req.getAuthorId());
    }

    private QuestionGroupResponse mapToResponse(QuestionGroup group) {
        return QuestionGroupResponse.builder()
                .id(group.getId())
                .skill(group.getSkill())
                .title(group.getTitle())
                .content(group.getContent())
                .mediaUrl(group.getMediaUrl())
                .mediaType(group.getMediaType())
                .difficultyBand(group.getDifficultyBand())
                .authorId(group.getAuthorId())
                .createdAt(group.getCreatedAt())
                .questions(group.getQuestions().stream()
                        .map(questionBankService::mapToResponse)
                        .collect(Collectors.toList()))
                .build();
    }
}
