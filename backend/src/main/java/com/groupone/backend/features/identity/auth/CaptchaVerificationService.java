package com.groupone.backend.features.identity.auth;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class CaptchaVerificationService {

    @Value("${recaptcha.secret.key}")
    private String recaptchaSecret;

    private static final String RECAPTCHA_VERIFY_URL = "https://www.google.com/recaptcha/api/siteverify";

    public boolean verifyToken(String token) {
        if (token == null || token.isEmpty()) {
            return false;
        }

        RestTemplate restTemplate = new RestTemplate();

        MultiValueMap<String, String> requestMap = new LinkedMultiValueMap<>();
        requestMap.add("secret", recaptchaSecret);
        requestMap.add("response", token);

        try {
            ResponseEntity<RecaptchaResponse> apiResponse = restTemplate.postForEntity(
                    RECAPTCHA_VERIFY_URL,
                    requestMap,
                    RecaptchaResponse.class);

            RecaptchaResponse body = apiResponse.getBody();
            if (body != null && body.isSuccess()) {
                return true;
            } else {
                log.warn("reCAPTCHA verification failed: {}", body != null ? body.getErrorCodes() : "No body");
                return false;
            }
        } catch (Exception e) {
            log.error("Error communicating with reCAPTCHA server", e);
            return false;
        }
    }

    @Data
    public static class RecaptchaResponse {
        private boolean success;
        private String challenge_ts;
        private String hostname;
        private List<String> errorCodes; // "error-codes" in JSON
    }
}
