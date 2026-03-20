package com.groupone.backend.features.quizbank.controller;

import com.groupone.backend.features.quizbank.dto.QuestionGroupRequest;
import com.groupone.backend.features.quizbank.dto.QuestionGroupResponse;
import com.groupone.backend.features.quizbank.enums.SkillType;
import com.groupone.backend.features.quizbank.service.QuestionGroupService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/quizbank/groups")
public class QuestionGroupController {

    @Autowired
    private QuestionGroupService questionGroupService;

    @GetMapping
    public ResponseEntity<List<QuestionGroupResponse>> getAllGroups(
            @RequestParam(required = false) SkillType skill) {
        return ResponseEntity.ok(questionGroupService.getAllGroups(skill));
    }

    @GetMapping("/{id}")
    public ResponseEntity<QuestionGroupResponse> getGroupById(@PathVariable Long id) {
        return ResponseEntity.ok(questionGroupService.getGroupById(id));
    }

    @PostMapping
    public ResponseEntity<QuestionGroupResponse> createGroup(@Valid @RequestBody QuestionGroupRequest req) {
        return ResponseEntity.ok(questionGroupService.createGroup(req));
    }

    @PutMapping("/{id}")
    public ResponseEntity<QuestionGroupResponse> updateGroup(
            @PathVariable Long id,
            @Valid @RequestBody QuestionGroupRequest req) {
        return ResponseEntity.ok(questionGroupService.updateGroup(id, req));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteGroup(@PathVariable Long id) {
        questionGroupService.deleteGroup(id);
        return ResponseEntity.noContent().build();
    }
}
