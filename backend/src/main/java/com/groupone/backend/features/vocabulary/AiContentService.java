package com.groupone.backend.features.vocabulary;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.ai.converter.BeanOutputConverter;
import org.springframework.ai.ollama.OllamaChatModel;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Random;

@Slf4j
@Service
@RequiredArgsConstructor
public class AiContentService {

    private final OllamaChatModel chatModel;
    private final VocabularyRepository vocabularyRepository;
    private final VocabularyPracticeAiContentRepository vocabularyPracticeAiContentRepository;
    private final VocabularyService vocabularyService;
    private final ObjectMapper objectMapper;
    private final Random random = new Random();

    @Cacheable(value = "vocabularyDetails", key = "#word")
    public VocabularyDetail generateDetails(String word) {
        log.info("Requesting details for word: {}", word);

        Optional<VocabularyEntity> existing = vocabularyRepository.findByWord(word);
        if (existing.isPresent() && existing.get().getDefinition() != null) {
            String synonymsJson = existing.get().getSynonymsJson();
            // If synonyms are missing, we don't return from DB/Cache, we proceed to AI generation
            if (synonymsJson != null && !synonymsJson.equals("[]") && !synonymsJson.isEmpty()) {
                log.info("Found details for '{}' in database storage.", word);
                try {
                    return VocabularyDetail.builder()
                            .definition(existing.get().getDefinition())
                            .examples(safeReadList(existing.get().getExamplesJson()))
                            .synonyms(safeReadList(synonymsJson))
                            .build();
                } catch (Exception e) {
                    log.error("Error building details from database: {}", e.getMessage());
                }
            } else {
                log.info("Details for '{}' exist but synonyms are missing. Re-generating...", word);
            }
        }

        log.info("Details not found for '{}'. Calling local AI...", word);
        BeanOutputConverter<VocabularyDetail> converter = new BeanOutputConverter<>(VocabularyDetail.class);

        String promptString = """
                Generate a detailed definition, exactly 2 example sentences, and exactly 3 synonyms for the English word or phrase: {word}.
                {format}
                """;

        PromptTemplate template = new PromptTemplate(promptString);
        Prompt prompt = template.create(Map.of("word", word, "format", converter.getFormat()));

        ChatResponse response = chatModel.call(prompt);
        String rawText = cleanAiResponse(response.getResult().getOutput().getText());
        log.info("Raw AI Response for word details '{}': {}", word, rawText);
        
        VocabularyDetail result = converter.convert(rawText);

        if (existing.isPresent()) {
            updateEntityWithDetails(existing.get(), result);
        } else {
            saveNewDetailsToDb(word, result);
        }

        return result;
    }

    public void ensureAiContent(String word) {
        log.info("Ensuring all AI content for word: {}", word);
        generateDetails(word);
        ensureFullPracticeSet(word);
    }

    public List<PracticeQuiz> ensureFullPracticeSet(String word) {
        String[] types = {"MULTIPLE_CHOICE", "FILL_IN_THE_BLANK"};
        List<PracticeQuiz> allQuizzes = new ArrayList<>();

        for (String type : types) {
            List<VocabularyPracticeAiContentEntity> existing = vocabularyPracticeAiContentRepository.findAllByWordAndQuizType(word, type);
            int countNeeded = 2 - existing.size();
            
            if (countNeeded > 0) {
                log.info("Generating {} missing {} quizzes for '{}'", countNeeded, type, word);
                for (int i = 0; i < countNeeded; i++) {
                    int attempts = 0;
                    boolean success = false;
                    while (attempts < 2 && !success) {
                        try {
                            allQuizzes.add(generateSpecificPractice(word, type));
                            success = true;
                        } catch (Exception e) {
                            attempts++;
                            log.error("Attempt {} failed to generate {} quiz for {}: {}", attempts, type, word, e.getMessage());
                            if (attempts >= 2) {
                                log.error("Giving up on generating {} quiz for {} after 2 attempts.", type, word);
                            }
                        }
                    }
                }
            }
        }
        return allQuizzes;
    }

    private PracticeQuiz generateSpecificPractice(String word, String selectedType) {
        log.info("Generating a new {} quiz for '{}'. Calling local AI...", selectedType, word);
        BeanOutputConverter<PracticeQuiz> converter = new BeanOutputConverter<>(PracticeQuiz.class);

        String promptString = """
                Generate ONE English practice quiz of type: {type} for the word or phrase: {word}.
                
                Requirements:
                - If type is MULTIPLE_CHOICE: provide 1 question, exactly 4 options, and the correct answer.
                  Example JSON: {{ "question": "What is a synonym for 'abandon'?", "options": ["leave", "stay", "keep", "hold"], "answer": "leave" }}
                - If type is MATCHING: provide exactly 4 pairs. Each pair should match a word related to '{word}' (including synonyms) with its meaning.
                  Example JSON: {{ "pairs": [{{ "word": "abandon", "meaning": "to leave forever" }}, {{ "word": "discard", "meaning": "to throw away" }}, ...] }}
                - If type is FILL_IN_THE_BLANK: provide 1 sentence with ___ as a blank, exactly 4 options for the blank, and the correct answer.
                  Example JSON: {{ "sentence": "They had to ___ the sinking ship.", "options": ["abandon", "adopt", "keep", "save"], "answer": "abandon" }}
                
                {format}
                """;

        PromptTemplate template = new PromptTemplate(promptString);
        Prompt prompt = template.create(Map.of("word", word, "type", selectedType, "format", converter.getFormat()));

        ChatResponse response = chatModel.call(prompt);
        String rawText = cleanAiResponse(response.getResult().getOutput().getText());
        log.info("Raw AI Response for {} quiz for '{}': {}", selectedType, word, rawText);
        
        PracticeQuiz result = converter.convert(rawText);
        result.setType(selectedType);

        savePracticeToDb(word, selectedType, result);
        return result;
    }

    public PracticeQuiz generatePractice(String word) {
        log.info("Requesting practice for word: {}", word);
        String[] types = {"MULTIPLE_CHOICE", "FILL_IN_THE_BLANK"};
        String selectedType = types[random.nextInt(types.length)];
        return generateSpecificPractice(word, selectedType);
    }

    private void updateEntityWithDetails(VocabularyEntity entity, VocabularyDetail content) {
        try {
            entity.setDefinition(content.getDefinition());
            entity.setExamplesJson(objectMapper.writeValueAsString(content.getExamples()));
            entity.setSynonymsJson(objectMapper.writeValueAsString(content.getSynonyms()));
            vocabularyRepository.save(entity);
            vocabularyService.recordHistory(entity, "AI_GENERATED");
            log.info("Updated AI details for '{}' and recorded history.", entity.getWord());
        } catch (JsonProcessingException e) {
            log.error("Failed to serialize details for update: {}", e.getMessage());
        }
    }

    private void saveNewDetailsToDb(String word, VocabularyDetail content) {
        try {
            VocabularyEntity entity = VocabularyEntity.builder()
                    .word(word)
                    .type("word")
                    .definition(content.getDefinition())
                    .examplesJson(objectMapper.writeValueAsString(content.getExamples()))
                    .synonymsJson(objectMapper.writeValueAsString(content.getSynonyms()))
                    .build();
            vocabularyRepository.save(entity);
            vocabularyService.recordHistory(entity, "AI_GENERATED");
            log.info("Saved new AI entry for '{}' and recorded history.", word);
        } catch (JsonProcessingException e) {
            log.error("Failed to serialize details for new entry: {}", e.getMessage());
        }
    }

    private void savePracticeToDb(String word, String type, PracticeQuiz content) {
        try {
            String json = objectMapper.writeValueAsString(content);
            VocabularyPracticeAiContentEntity entity = VocabularyPracticeAiContentEntity.builder()
                    .word(word)
                    .quizType(type)
                    .jsonContent(json)
                    .version(1)
                    .build();
            vocabularyPracticeAiContentRepository.save(entity);
            vocabularyService.recordPracticeHistory(entity, "AI_GENERATED");
            log.info("Saved AI generated {} quiz for '{}' and recorded history.", type, word);
        } catch (JsonProcessingException e) {
            log.error("Failed to serialize practice JSON: {}", e.getMessage());
        }
    }

    private List<String> safeReadList(String json) {
        if (json == null || json.isEmpty()) return new ArrayList<>();
        try {
            return objectMapper.readValue(json, new TypeReference<List<String>>() {});
        } catch (JsonProcessingException e) {
            log.error("Failed to parse JSON list: {}", e.getMessage());
            return new ArrayList<>();
        }
    }

    private String cleanAiResponse(String rawText) {
        if (rawText == null) return "";
        
        String cleaned = rawText.trim();
        if (cleaned.contains("```json")) {
            cleaned = cleaned.substring(cleaned.indexOf("```json") + 7);
            if (cleaned.contains("```")) {
                cleaned = cleaned.substring(0, cleaned.indexOf("```"));
            }
        } else if (cleaned.contains("```")) {
            cleaned = cleaned.substring(cleaned.indexOf("```") + 3);
            if (cleaned.contains("```")) {
                cleaned = cleaned.substring(0, cleaned.indexOf("```"));
            }
        }
        return cleaned.trim();
    }
}
