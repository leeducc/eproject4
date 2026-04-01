package com.groupone.backend.features.appconfig.service;

import com.groupone.backend.features.appconfig.dto.AppScreenSectionRequest;
import com.groupone.backend.features.appconfig.dto.AppScreenSectionResponse;
import com.groupone.backend.features.appconfig.entity.AppScreenSection;
import com.groupone.backend.features.appconfig.repository.AppScreenSectionRepository;
import com.groupone.backend.features.quizbank.entity.Tag;
import com.groupone.backend.features.quizbank.repository.TagRepository;
import com.groupone.backend.features.quizbank.dto.FilterGroup;
import com.groupone.backend.features.quizbank.dto.FilterRequest;
import com.groupone.backend.features.quizbank.service.QuestionFilterService;
import com.groupone.backend.features.ranking.repository.UserSectionStatsRepository;
import com.groupone.backend.features.ranking.entity.UserSectionStats;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.Authentication;
import com.groupone.backend.features.identity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AppScreenSectionService {
    private final AppScreenSectionRepository repository;
    private final TagRepository tagRepository;
    private final QuestionFilterService questionFilterService;
    private final UserSectionStatsRepository userSectionStatsRepository;

    @Transactional(readOnly = true)
    public List<AppScreenSectionResponse> getSections(String skill, String difficultyBand) {
        Long userId = getCurrentUserId();
        List<AppScreenSection> sections;
        
        // Normalize skill to uppercase to match DB values like "LISTENING"
        String normalizedSkill = (skill != null) ? skill.toUpperCase() : null;

        if (normalizedSkill != null && difficultyBand != null) {
            sections = repository.findBySkillAndDifficultyBandOrderByDisplayOrderAsc(normalizedSkill, difficultyBand);
        } else {
            sections = repository.findAllByOrderBySkillAscDifficultyBandAscDisplayOrderAsc();
        }
        return sections.stream().map(s -> mapToResponse(s, userId)).collect(Collectors.toList());
    }

    private Long getCurrentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof User user) {
            return user.getId();
        }
        return null;
    }

    @Transactional
    public AppScreenSectionResponse createSection(AppScreenSectionRequest request) {
        List<Tag> tags = new ArrayList<>();
        if (request.getTagIds() != null && !request.getTagIds().isEmpty()) {
            tags = tagRepository.findAllById(request.getTagIds());
        }

        AppScreenSection section = AppScreenSection.builder()
                .skill(request.getSkill())
                .sectionName(request.getSectionName())
                .difficultyBand(request.getDifficultyBand())
                .displayOrder(request.getDisplayOrder())
                .tags(tags)
                .guideContent(request.getGuideContent())
                .build();

        validateDisplayOrder(section);
        AppScreenSection saved = repository.save(section);
        return mapToResponse(saved, null);
    }

    @Transactional
    public AppScreenSectionResponse updateSection(Long id, AppScreenSectionRequest request) {
        AppScreenSection section = repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Section not found"));

        List<Tag> tags = new ArrayList<>();
        if (request.getTagIds() != null && !request.getTagIds().isEmpty()) {
            tags = tagRepository.findAllById(request.getTagIds());
        }

        section.setSkill(request.getSkill());
        section.setSectionName(request.getSectionName());
        section.setDifficultyBand(request.getDifficultyBand());
        section.setDisplayOrder(request.getDisplayOrder());
        section.setTags(tags);
        section.setGuideContent(request.getGuideContent());

        validateDisplayOrder(section);
        AppScreenSection saved = repository.save(section);
        return mapToResponse(saved, null);
    }

    @Transactional
    public void deleteSection(Long id) {
        if (!repository.existsById(id)) {
            throw new IllegalArgumentException("Section not found");
        }
        repository.deleteById(id);
    }

    private void validateDisplayOrder(AppScreenSection newSection) {
        // Optional logic implementation
    }

    private AppScreenSectionResponse mapToResponse(AppScreenSection section, Long userId) {
        int questionCount = 0;
        if (section.getTags() != null && !section.getTags().isEmpty()) {
            FilterRequest request = new FilterRequest();
            request.setLogic("AND");
            FilterGroup group = new FilterGroup();
            group.setLogic("OR");
            group.setTags(section.getTags().stream()
                    .map(t -> t.getNamespace() + ":" + t.getName())
                    .collect(Collectors.toList()));
            request.setGroups(List.of(group));
            questionCount = questionFilterService.filterQuestions(request).size();
        }

        double mastery = 0.0;
        if (userId != null) {
            mastery = userSectionStatsRepository.findByUserIdAndSectionId(userId, section.getId())
                    .map(stats -> {
                        if (stats.getTotalQuestionsAttempted() == 0) return 0.0;
                        return (double) stats.getTotalCorrectAnswers() / stats.getTotalQuestionsAttempted() * 100;
                    })
                    .orElse(0.0);
        }

        return AppScreenSectionResponse.builder()
                .id(section.getId())
                .skill(section.getSkill())
                .sectionName(section.getSectionName())
                .difficultyBand(section.getDifficultyBand())
                .displayOrder(section.getDisplayOrder())
                .tags(section.getTags() != null ? new ArrayList<>(section.getTags()) : new ArrayList<>())
                .guideContent(section.getGuideContent())
                .questionCount(questionCount)
                .mastery(mastery)
                .build();
    }
}
