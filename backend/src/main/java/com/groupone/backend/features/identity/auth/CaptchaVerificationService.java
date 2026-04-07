package com.groupone.backend.features.identity.auth;

import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.time.Duration;
import java.util.List;

@Slf4j
@Service
public class CaptchaVerificationService {

    @Value("${recaptcha.secret.key}")
    private String recaptchaSecret;

    private static final String RECAPTCHA_VERIFY_URL = "https://www.google.com/recaptcha/api/siteverify";

    
    private final RestTemplate restTemplate;

    public CaptchaVerificationService(RestTemplateBuilder builder) {
        this.restTemplate = builder
                .connectTimeout(Duration.ofSeconds(5))
                .readTimeout(Duration.ofSeconds(5))
                .build();
        log.info("[CaptchaVerificationService] RestTemplate initialized with 5s connect/read timeout");
    }

    public boolean verifyToken(String token) {
        if (token == null || token.isEmpty()) {
            log.warn("[CaptchaVerificationService] verifyToken called with null/empty token");
            return false;
        }

        MultiValueMap<String, String> requestMap = new LinkedMultiValueMap<>();
        requestMap.add("secret", recaptchaSecret);
        requestMap.add("response", token);

        try {
            log.debug("[CaptchaVerificationService] Sending captcha verification request");
            ResponseEntity<RecaptchaResponse> apiResponse = restTemplate.postForEntity(
                    RECAPTCHA_VERIFY_URL,
                    requestMap,
                    RecaptchaResponse.class);

            RecaptchaResponse body = apiResponse.getBody();
            if (body != null && body.isSuccess()) {
                log.debug("[CaptchaVerificationService] Captcha verified successfully");
                return true;
            } else {
                log.warn("reCAPTCHA verification failed: {}", body != null ? body.getErrorCodes() : "No body");
                return false;
            }
        } catch (Exception e) {
            log.error("[CaptchaVerificationService] Error communicating with reCAPTCHA server: {}", e.getMessage());
            return false;
        }
    }

    @Data
    public static class RecaptchaResponse {
        private boolean success;
        private String challenge_ts;
        private String hostname;
        private List<String> errorCodes; 
    }
}
