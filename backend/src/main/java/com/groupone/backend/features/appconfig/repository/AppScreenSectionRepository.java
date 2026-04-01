package com.groupone.backend.features.appconfig.repository;

import com.groupone.backend.features.appconfig.entity.AppScreenSection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AppScreenSectionRepository extends JpaRepository<AppScreenSection, Long> {
    List<AppScreenSection> findBySkillAndDifficultyBandOrderByDisplayOrderAsc(String skill, String difficultyBand);
    List<AppScreenSection> findAllByOrderBySkillAscDifficultyBandAscDisplayOrderAsc();
}
