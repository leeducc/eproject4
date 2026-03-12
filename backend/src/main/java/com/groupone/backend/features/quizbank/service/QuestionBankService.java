package com.groupone.backend.features.quizbank.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.groupone.backend.features.quizbank.dto.QuestionRequest;
import com.groupone.backend.features.quizbank.dto.QuestionResponse;
import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.enums.QuestionType;
import com.groupone.backend.features.quizbank.enums.SkillType;
import com.groupone.backend.features.quizbank.repository.QuestionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.util.StringUtils;

@Service
public class QuestionBankService {

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private ObjectMapper objectMapper;

    public List<QuestionResponse> getAllQuestions(SkillType skill) {
        List<Question> questions = (skill != null) ? questionRepository.findBySkill(skill)
                : questionRepository.findAll();

        return questions.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    public QuestionResponse getQuestionById(Long id) {
        Question q = questionRepository.findById(id).orElseThrow(() -> new RuntimeException("Question not found"));
        return mapToResponse(q);
    }

    public QuestionResponse createQuestion(QuestionRequest req, List<MultipartFile> mediaFiles) {
        Question q = new Question();
        mapToEntity(req, q);
        Map<String, String> fileNameToUrl = handleMediaUpload(q, mediaFiles, req.getRetainedMediaUrls());
        
        // Post-process data to replace placeholders
        if (q.getData() != null && !fileNameToUrl.isEmpty()) {
            q.setData(replacePlaceholders(q.getData(), fileNameToUrl));
        }
        
        Question saved = questionRepository.save(q);
        return mapToResponse(saved);
    }

    public QuestionResponse updateQuestion(Long id, QuestionRequest req, List<MultipartFile> mediaFiles) {
        Question q = questionRepository.findById(id).orElseThrow(() -> new RuntimeException("Question not found"));
        mapToEntity(req, q);
        Map<String, String> fileNameToUrl = handleMediaUpload(q, mediaFiles, req.getRetainedMediaUrls());
        
        // Post-process data to replace placeholders
        if (q.getData() != null && !fileNameToUrl.isEmpty()) {
            q.setData(replacePlaceholders(q.getData(), fileNameToUrl));
        }
        
        Question saved = questionRepository.save(q);
        return mapToResponse(saved);
    }

    private String replacePlaceholders(String jsonData, Map<String, String> fileNameToUrl) {
        try {
            Map<String, Object> dataMap = objectMapper.readValue(jsonData, Map.class);
            boolean modified = replaceRecursive(dataMap, fileNameToUrl);
            return modified ? objectMapper.writeValueAsString(dataMap) : jsonData;
        } catch (IOException e) {
            System.err.println("[QuestionBankService] Failed to replace placeholders: " + e.getMessage());
            return jsonData;
        }
    }

    private boolean replaceRecursive(Object target, Map<String, String> fileNameToUrl) {
        boolean modified = false;
        if (target instanceof Map) {
            Map<String, Object> map = (Map<String, Object>) target;
            for (Map.Entry<String, Object> entry : map.entrySet()) {
                Object val = entry.getValue();
                if (val instanceof String) {
                    String s = (String) val;
                    if (s.startsWith("@media:")) {
                        String fileName = s.substring(7);
                        if (fileNameToUrl.containsKey(fileName)) {
                            entry.setValue(fileNameToUrl.get(fileName));
                            modified = true;
                        }
                    }
                } else if (val instanceof Map || val instanceof List) {
                    if (replaceRecursive(val, fileNameToUrl)) modified = true;
                }
            }
        } else if (target instanceof List) {
            List<Object> list = (List<Object>) target;
            for (int i = 0; i < list.size(); i++) {
                Object val = list.get(i);
                if (val instanceof String) {
                    String s = (String) val;
                    if (s.startsWith("@media:")) {
                        String fileName = s.substring(7);
                        if (fileNameToUrl.containsKey(fileName)) {
                            list.set(i, fileNameToUrl.get(fileName));
                            modified = true;
                        }
                    }
                } else if (val instanceof Map || val instanceof List) {
                    if (replaceRecursive(val, fileNameToUrl)) modified = true;
                }
            }
        }
        return modified;
    }

    private Map<String, String> handleMediaUpload(Question q, List<MultipartFile> mediaFiles, List<String> retainedMediaUrls) {
        Map<String, String> fileNameToUrl = new java.util.HashMap<>();
        List<String> finalUrls = new ArrayList<>();
        List<String> finalTypes = new ArrayList<>();

        // 1. Identify and delete removed files
        List<String> currentUrls = q.getMediaUrl() != null ? Arrays.asList(q.getMediaUrl().split(","))
                : new ArrayList<>();
        if (retainedMediaUrls == null)
            retainedMediaUrls = new ArrayList<>();

        for (String url : currentUrls) {
            if (!retainedMediaUrls.contains(url)) {
                deleteFileFromStorage(url);
            }
        }

        // 2. Process Retained Media
        if (!retainedMediaUrls.isEmpty()) {
            List<String> existingTypes = q.getMediaType() != null ? Arrays.asList(q.getMediaType().split(","))
                    : new ArrayList<>();

            for (int i = 0; i < currentUrls.size(); i++) {
                if (retainedMediaUrls.contains(currentUrls.get(i))) {
                    finalUrls.add(currentUrls.get(i));
                    if (i < existingTypes.size()) {
                        finalTypes.add(existingTypes.get(i));
                    }
                }
            }
        }

        // 3. Process New Media Files
        if (mediaFiles != null && !mediaFiles.isEmpty()) {
            for (MultipartFile media : mediaFiles) {
                if (!media.isEmpty()) {
                    try {
                        String uploadDir = "uploads/questions/";
                        Path uploadPath = Paths.get(uploadDir);
                        if (!Files.exists(uploadPath)) {
                            Files.createDirectories(uploadPath);
                        }

                        String originalFilename = StringUtils.cleanPath(media.getOriginalFilename());
                        String extension = "";
                        int dotIndex = originalFilename.lastIndexOf('.');
                        if (dotIndex > 0) {
                            extension = originalFilename.substring(dotIndex);
                        }

                        String uniqueFilename = UUID.randomUUID().toString() + extension;
                        Path filePath = uploadPath.resolve(uniqueFilename);
                        Files.copy(media.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

                         finalUrls.add("/media/questions/" + uniqueFilename);
                        finalTypes.add(media.getContentType());
                        fileNameToUrl.put(originalFilename, "/media/questions/" + uniqueFilename);
                    } catch (IOException e) {
                        throw new RuntimeException("Could not store media file", e);
                    }
                }
            }
        }

        // 4. Update Entity
        if (!finalUrls.isEmpty()) {
            q.setMediaUrl(String.join(",", finalUrls));
            q.setMediaType(String.join(",", finalTypes));
        } else {
            q.setMediaUrl(null);
            q.setMediaType(null);
        }
        return fileNameToUrl;
    }

    private void deleteFileFromStorage(String mediaUrl) {
        if (mediaUrl == null || !mediaUrl.startsWith("/media/questions/"))
            return;

        try {
            String filename = mediaUrl.replace("/media/questions/", "");
            Path filePath = Paths.get("uploads/questions/").resolve(filename);
            Files.deleteIfExists(filePath);
            System.out.println("[QuestionBankService] Deleted file: " + filePath);
        } catch (IOException e) {
            System.err.println("[QuestionBankService] Failed to delete file: " + mediaUrl + " - " + e.getMessage());
        }
    }

    public void deleteQuestion(Long id) {
        Question q = questionRepository.findById(id).orElse(null);
        if (q != null && q.getMediaUrl() != null) {
            String[] urls = q.getMediaUrl().split(",");
            for (String url : urls) {
                deleteFileFromStorage(url.trim());
            }
        }
        questionRepository.deleteById(id);
    }

    private void mapToEntity(QuestionRequest req, Question q) {
        q.setSkill(req.getSkill());
        q.setType(req.getType());
        q.setDifficultyBand(req.getDifficultyBand());
        q.setIsPremiumContent(req.getIsPremiumContent());
        q.setInstruction(req.getInstruction());
        q.setExplanation(req.getExplanation());

        if (req.getType() == QuestionType.ESSAY && req.getSkill() != SkillType.WRITING) {
            throw new IllegalArgumentException("Question type ESSAY is only allowed for WRITING skill.");
        }

        if (req.getMediaUrls() != null && !req.getMediaUrls().isEmpty()) {
            q.setMediaUrl(String.join(",", req.getMediaUrls()));
        }
        if (req.getMediaTypes() != null && !req.getMediaTypes().isEmpty()) {
            q.setMediaType(String.join(",", req.getMediaTypes()));
        }

        try {
            Map<String, Object> dataMap = req.getData() != null
                    ? new java.util.HashMap<>(req.getData())
                    : new java.util.HashMap<>();
            q.setData(objectMapper.writeValueAsString(dataMap));
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Error converting data to JSON", e);
        }
    }

    @SuppressWarnings("unchecked")
    public QuestionResponse mapToResponse(Question q) {
        Map<String, Object> dataMap = null;
        try {
            if (q.getData() != null) {
                dataMap = objectMapper.readValue(q.getData(), Map.class);
            }
        } catch (JsonProcessingException e) {

        }

        return QuestionResponse.builder()
                .id(q.getId())
                .skill(q.getSkill())
                .type(q.getType())
                .difficultyBand(q.getDifficultyBand())
                .data(dataMap)
                .isPremiumContent(q.getIsPremiumContent())
                .instruction(q.getInstruction())
                .explanation(q.getExplanation())
                .mediaUrls(q.getMediaUrl() != null && !q.getMediaUrl().isEmpty()
                        ? Arrays.asList(q.getMediaUrl().split(","))
                        : new ArrayList<>())
                .mediaTypes(q.getMediaType() != null && !q.getMediaType().isEmpty()
                        ? Arrays.asList(q.getMediaType().split(","))
                        : new ArrayList<>())
                .build();
    }
}
