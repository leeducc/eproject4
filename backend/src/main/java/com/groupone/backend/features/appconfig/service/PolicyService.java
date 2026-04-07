package com.groupone.backend.features.appconfig.service;

import com.groupone.backend.features.appconfig.dto.PolicyDto;
import com.groupone.backend.features.appconfig.dto.PolicyHistoryDto;
import com.groupone.backend.features.appconfig.entity.Policy;
import com.groupone.backend.features.appconfig.entity.PolicyHistory;
import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.appconfig.repository.PolicyHistoryRepository;
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
    private final PolicyHistoryRepository policyHistoryRepository;

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

    public List<PolicyHistoryDto> getPolicyHistory(String type) {
        log.info("Fetching history for policy type: {}", type);
        return policyHistoryRepository.findAllByTypeOrderByChangedAtDesc(type).stream()
                .map(this::toHistoryDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public PolicyDto updatePolicy(PolicyDto dto, User admin) {
        log.info("Updating policy type: {} by admin: {}", dto.getType(), admin.getEmail());
        Policy policy = policyRepository.findByType(dto.getType())
                .orElse(new Policy());

        policy.setType(dto.getType());
        policy.setTitleEn(dto.getTitleEn());
        policy.setTitleVi(dto.getTitleVi());
        policy.setTitleZh(dto.getTitleZh());
        policy.setContentEn(dto.getContentEn());
        policy.setContentVi(dto.getContentVi());
        policy.setContentZh(dto.getContentZh());

        Policy savedPolicy = policyRepository.save(policy);
        
        
        savePolicyHistorySnapshot(savedPolicy, admin);
        
        return toDto(savedPolicy);
    }

    private void savePolicyHistorySnapshot(Policy policy, User admin) {
        PolicyHistory history = PolicyHistory.builder()
                .policy(policy)
                .type(policy.getType())
                .titleEn(policy.getTitleEn())
                .titleVi(policy.getTitleVi())
                .titleZh(policy.getTitleZh())
                .contentEn(policy.getContentEn())
                .contentVi(policy.getContentVi())
                .contentZh(policy.getContentZh())
                .admin(admin)
                .build();
        policyHistoryRepository.save(history);
        log.info("Saved history snapshot for policy: {} by {}", policy.getType(), admin.getEmail());
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

    private PolicyHistoryDto toHistoryDto(PolicyHistory history) {
        return PolicyHistoryDto.builder()
                .id(history.getId())
                .type(history.getType())
                .titleEn(history.getTitleEn())
                .titleVi(history.getTitleVi())
                .titleZh(history.getTitleZh())
                .contentEn(history.getContentEn())
                .contentVi(history.getContentVi())
                .contentZh(history.getContentZh())
                .adminId(history.getAdmin().getId())
                .adminEmail(history.getAdmin().getEmail())
                .changedAt(history.getChangedAt())
                .build();
    }
}
