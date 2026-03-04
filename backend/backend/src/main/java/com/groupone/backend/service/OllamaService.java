package com.groupone.backend.service;

import com.groupone.backend.dto.OllamaRequest;
import com.groupone.backend.dto.OllamaResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
@RequiredArgsConstructor
public class OllamaService {

    private final RestTemplate restTemplate;

    @Value("${ollama.api.url:http://localhost:11434/api/generate}")
    private String ollamaApiUrl;

    @Value("${ollama.model.name:gemma3:4b}")
    private String modelName;

    public String generateGradingFeedback(String topic, String content) {
        String prompt = "You are an expert IELTS examiner. Grade the following essay.\n\n" +
                "Topic: " + topic + "\n\n" +
                "Essay:\n" + content + "\n\n" +
                "Provide detailed feedback on vocabulary, grammar, and structure, and estimate a band score.";

        OllamaRequest requestDto = new OllamaRequest(modelName, prompt, false);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<OllamaRequest> entity = new HttpEntity<>(requestDto, headers);

        ResponseEntity<OllamaResponse> response = restTemplate.postForEntity(ollamaApiUrl, entity,
                OllamaResponse.class);

        if (response.getBody() != null && response.getBody().getResponse() != null) {
            return response.getBody().getResponse();
        }

        return "Error: Unable to generate feedback from AI.";
    }
}
