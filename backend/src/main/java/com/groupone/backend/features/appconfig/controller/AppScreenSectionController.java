package com.groupone.backend.features.appconfig.controller;

import com.groupone.backend.features.appconfig.dto.AppScreenSectionRequest;
import com.groupone.backend.features.appconfig.dto.AppScreenSectionResponse;
import com.groupone.backend.features.appconfig.service.AppScreenSectionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/app-sections")
@RequiredArgsConstructor
public class AppScreenSectionController {

    private final AppScreenSectionService service;

    @GetMapping
    public ResponseEntity<List<AppScreenSectionResponse>> getSections(
            @RequestParam(required = false) String skill,
            @RequestParam(required = false) String difficultyBand) {
        return ResponseEntity.ok(service.getSections(skill, difficultyBand));
    }

    @PostMapping
    public ResponseEntity<AppScreenSectionResponse> createSection(@RequestBody AppScreenSectionRequest request) {
        return ResponseEntity.ok(service.createSection(request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<AppScreenSectionResponse> updateSection(@PathVariable Long id, @RequestBody AppScreenSectionRequest request) {
        return ResponseEntity.ok(service.updateSection(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSection(@PathVariable Long id) {
        service.deleteSection(id);
        return ResponseEntity.noContent().build();
    }
}
