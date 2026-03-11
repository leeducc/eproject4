package com.groupone.backend.features.writing;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
@Slf4j
public class OllamaService {

    private final RestTemplate restTemplate = new RestTemplate();
    private final String OLLAMA_URL = "http://localhost:11434/api/generate";
    private final String MODEL_NAME = "llama3.2"; // or whatever model is available

    public OllamaGradingResult gradeEssay(String topicDescription, String essayContent) {
        log.info("Requesting essay grading from local Ollama ({})", MODEL_NAME);

        String prompt = "You are an expert English teacher. The user has written an essay based on the following topic:\n" +
                "Topic: " + topicDescription + "\n\n" +
                "User's Essay: " + essayContent + "\n\n" +
                "Please provide two things:\n" +
                "1. A score between 0.0 and 10.0 representing the quality of the essay.\n" +
                "2. Constructive feedback explaining the score and how the user can improve.\n" +
                "Format your response EXACTLY as follows:\n" +
                "SCORE: <number>\n" +
                "FEEDBACK:\n<your detailed feedback>";

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", MODEL_NAME);
        requestBody.put("prompt", prompt);
        requestBody.put("stream", false);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(OLLAMA_URL, entity, Map.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                String responseText = (String) response.getBody().get("response");
                log.info("Received response from Ollama: {}", responseText);

                return parseOllamaResponse(responseText);
            }
        } catch (Exception e) {
            log.error("Failed to call Ollama API for grading", e);
        }

        return new OllamaGradingResult(0.0, "AI Grading failed. Please try again later.");
    }

    private OllamaGradingResult parseOllamaResponse(String responseText) {
        Double score = null;
        String feedback = responseText;

        // Extract score using Regex
        Pattern scorePattern = Pattern.compile("SCORE:\\s*([0-9]*\\.?[0-9]+)", Pattern.CASE_INSENSITIVE);
        Matcher scoreMatcher = scorePattern.matcher(responseText);
        if (scoreMatcher.find()) {
            try {
                score = Double.parseDouble(scoreMatcher.group(1));
            } catch (NumberFormatException e) {
                log.warn("Could not parse score from Ollama response: {}", scoreMatcher.group(1));
            }
        }

        // Extract feedback (everything after FEEDBACK:)
        Pattern feedbackPattern = Pattern.compile("FEEDBACK:\\s*(.*)", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
        Matcher feedbackMatcher = feedbackPattern.matcher(responseText);
        if (feedbackMatcher.find()) {
            feedback = feedbackMatcher.group(1).trim();
        }

        if (score == null) {
            // Fallback if parsing fails but we got a response
            score = 0.0;
        }

        return new OllamaGradingResult(score, feedback);
    }

    public record OllamaGradingResult(Double score, String feedback) {}
}
