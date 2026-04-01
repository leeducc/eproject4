package com.groupone.backend.features.faq.service;

import com.groupone.backend.features.faq.dto.FAQDto;
import com.groupone.backend.features.faq.entity.FAQ;
import com.groupone.backend.features.faq.repository.FAQRepository;
import com.groupone.backend.shared.exception.AppException;
import com.groupone.backend.shared.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class FAQService {
    private final FAQRepository faqRepository;

    public List<FAQDto> getActiveFAQs() {
        log.info("Fetching active FAQs");
        return faqRepository.findAllByIsActiveOrderByDisplayOrderAsc(true)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<FAQDto> getAllFAQs() {
        log.info("Fetching all FAQs for admin");
        return faqRepository.findAllByOrderByDisplayOrderAsc()
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public FAQDto createFAQ(FAQDto dto) {
        log.info("Creating new FAQ: {}", dto.getQuestionEn());
        FAQ faq = FAQ.builder()
                .questionEn(dto.getQuestionEn())
                .questionVi(dto.getQuestionVi())
                .questionZh(dto.getQuestionZh())
                .answerEn(dto.getAnswerEn())
                .answerVi(dto.getAnswerVi())
                .answerZh(dto.getAnswerZh())
                .displayOrder(dto.getDisplayOrder() != null ? dto.getDisplayOrder() : 0)
                .isActive(dto.getIsActive() != null ? dto.getIsActive() : true)
                .build();
        return toDto(faqRepository.save(faq));
    }

    @Transactional
    public FAQDto updateFAQ(Long id, FAQDto dto) {
        log.info("Updating FAQ id: {}", id);
        FAQ faq = faqRepository.findById(id)
                .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND, "FAQ not found with id: " + id));

        faq.setQuestionEn(dto.getQuestionEn());
        faq.setQuestionVi(dto.getQuestionVi());
        faq.setQuestionZh(dto.getQuestionZh());
        faq.setAnswerEn(dto.getAnswerEn());
        faq.setAnswerVi(dto.getAnswerVi());
        faq.setAnswerZh(dto.getAnswerZh());
        faq.setDisplayOrder(dto.getDisplayOrder());
        faq.setIsActive(dto.getIsActive());

        return toDto(faqRepository.save(faq));
    }

    @Transactional
    public void deleteFAQ(Long id) {
        log.info("Deleting FAQ id: {}", id);
        if (!faqRepository.existsById(id)) {
            throw new AppException(ErrorCode.RESOURCE_NOT_FOUND, "FAQ not found with id: " + id);
        }
        faqRepository.deleteById(id);
    }

    private FAQDto toDto(FAQ faq) {
        return FAQDto.builder()
                .id(faq.getId())
                .questionEn(faq.getQuestionEn())
                .questionVi(faq.getQuestionVi())
                .questionZh(faq.getQuestionZh())
                .answerEn(faq.getAnswerEn())
                .answerVi(faq.getAnswerVi())
                .answerZh(faq.getAnswerZh())
                .displayOrder(faq.getDisplayOrder())
                .isActive(faq.getIsActive())
                .createdAt(faq.getCreatedAt())
                .updatedAt(faq.getUpdatedAt())
                .build();
    }
}
