package com.groupone.backend.config;

import com.groupone.backend.features.appconfig.entity.Policy;
import com.groupone.backend.features.appconfig.repository.PolicyRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
@Order(3)
@RequiredArgsConstructor
@Slf4j
public class PolicyDataSeeder implements CommandLineRunner {

    private final PolicyRepository policyRepository;

    @Override
    public void run(String... args) throws Exception {
        seedPolicy("TERMS", "Terms of Service", "Điều khoản Dịch vụ", 
            "<h1>Terms of Service</h1><p>Standard terms and conditions for our application.</p>");
        
        seedPolicy("PRIVACY", "Privacy Policy", "Chính sách Bảo mật", 
            "<h1>Privacy Policy</h1><p>Standard privacy policy for our application.</p>");
            
        seedPolicy("DELETE_ACCOUNT", "Account Deletion Policy", "Chính sách Xóa tài khoản", 
            "<h2>Before you proceed with deleting your account, please read following:</h2>" +
            "<ul>" +
            "<li><strong>Deletion is Permanent:</strong> Once your account is deleted, all data will be permanently removed.</li>" +
            "<li><strong>Subscription:</strong> Any active subscriptions will be forfeit.</li>" +
            "<li><strong>Processing Time:</strong> It may take up to 30 days to fully remove all associated data.</li>" +
            "</ul>" +
            "<p>By confirming, you acknowledge that you have read and understood these terms.</p>");
    }

    private void seedPolicy(String type, String titleEn, String titleVi, String contentEn) {
        if (policyRepository.findByType(type).isEmpty()) {
            Policy policy = Policy.builder()
                    .type(type)
                    .titleEn(titleEn)
                    .titleVi(titleVi)
                    .titleZh(titleEn) 
                    .contentEn(contentEn)
                    .contentVi(contentEn) 
                    .contentZh(contentEn) 
                    .build();
            policyRepository.save(policy);
            log.info("[PolicyDataSeeder] Seeded policy: {}", type);
        }
    }
}
