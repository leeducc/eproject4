package com.groupone.backend.features.appconfig.service;

import com.groupone.backend.features.appconfig.dto.PolicyDto;
import com.groupone.backend.features.appconfig.entity.Policy;
import com.groupone.backend.features.appconfig.repository.PolicyRepository;
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
public class PolicyService {
    private final PolicyRepository policyRepository;

    public List<PolicyDto> getAllPolicies() {
        return policyRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public PolicyDto getPolicyByType(String type) {
        log.info("Fetching policy by type: {}", type);
        return policyRepository.findByType(type)
                .map(this::toDto)
                .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND, "Policy not found with type: " + type));
    }

    @Transactional
    public PolicyDto updatePolicy(PolicyDto dto) {
        log.info("Updating policy type: {}", dto.getType());
        Policy policy = policyRepository.findByType(dto.getType())
                .orElse(new Policy());

        policy.setType(dto.getType());
        policy.setTitleEn(dto.getTitleEn());
        policy.setTitleVi(dto.getTitleVi());
        policy.setTitleZh(dto.getTitleZh());
        policy.setContentEn(dto.getContentEn());
        policy.setContentVi(dto.getContentVi());
        policy.setContentZh(dto.getContentZh());

        return toDto(policyRepository.save(policy));
    }

    private PolicyDto toDto(Policy policy) {
        return PolicyDto.builder()
                .id(policy.getId())
                .type(policy.getType())
                .titleEn(policy.getTitleEn())
                .titleVi(policy.getTitleVi())
                .titleZh(policy.getTitleZh())
                .contentEn(policy.getContentEn())
                .contentVi(policy.getContentVi())
                .contentZh(policy.getContentZh())
                .updatedAt(policy.getUpdatedAt())
                .build();
    }
}
