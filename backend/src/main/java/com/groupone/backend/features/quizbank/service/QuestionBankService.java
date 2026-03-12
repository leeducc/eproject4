package com.groupone.backend.features.quizbank.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.groupone.backend.features.quizbank.dto.PaginatedResponse;
import com.groupone.backend.features.quizbank.dto.QuestionRequest;
import com.groupone.backend.features.quizbank.dto.QuestionResponse;
import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.enums.DifficultyBand;
import com.groupone.backend.features.quizbank.enums.QuestionType;
import com.groupone.backend.features.quizbank.enums.SkillType;
import com.groupone.backend.features.quizbank.repository.QuestionRepository;
import com.groupone.backend.features.media.MediaFileRepository;
import com.groupone.backend.features.media.MediaFile;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
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
    private MediaFileRepository mediaFileRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @Value("${media.upload.dir:d:/project/eproject4/backend/uploads}")
    private String baseUploadDir;

    public List<QuestionResponse> getAllQuestions(SkillType skill) {
        List<Question> questions = (skill != null) ? questionRepository.findBySkill(skill)
                : questionRepository.findAll();

        return questions.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    public PaginatedResponse<QuestionResponse> getQuestionsPaginated(
            SkillType skill, 
            QuestionType type, 
            DifficultyBand difficulty, 
            String search,
            Long lastSeenId, 
            int limit) {
            
        List<Question> questions = questionRepository.findPaginated(
                skill != null ? skill.name() : null,
                type != null ? type.name() : null,
                difficulty != null ? difficulty.name() : null,
                search,
                lastSeenId,
                limit
        );

        List<QuestionResponse> responses = questions.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());

        Long nextCursor = null;
        boolean hasMore = questions.size() >= limit;
        if (!questions.isEmpty()) {
            nextCursor = questions.get(questions.size() - 1).getId();
        }

        return PaginatedResponse.<QuestionResponse>builder()
                .items(responses)
                .nextCursor(nextCursor)
                .hasMore(hasMore)
                .build();
    }

    public QuestionResponse getQuestionById(Long id) {
        Question q = questionRepository.findById(id).orElseThrow(() -> new RuntimeException("Question not found"));
        return mapToResponse(q);
    }

    public QuestionResponse createQuestion(QuestionRequest req, List<MultipartFile> mediaFiles) {
        Question q = new Question();
        mapToEntity(req, q);
        Map<String, String> fileNameToUrl = handleMediaUpload(q, mediaFiles, req.getRetainedMediaUrls(), null);
        
        // Post-process data to replace placeholders
        if (q.getData() != null && !fileNameToUrl.isEmpty()) {
            q.setData(replacePlaceholders(q.getData(), fileNameToUrl));
        }
        
        Question saved = questionRepository.save(q);
        return mapToResponse(saved);
    }

    public QuestionResponse updateQuestion(Long id, QuestionRequest req, List<MultipartFile> mediaFiles) {
        Question q = questionRepository.findById(id).orElseThrow(() -> new RuntimeException("Question not found"));
        String originalUrls = q.getMediaUrl();
        mapToEntity(req, q);
        Map<String, String> fileNameToUrl = handleMediaUpload(q, mediaFiles, req.getRetainedMediaUrls(), originalUrls);
        
        // Post-process data to replace placeholders
        if (q.getData() != null && !fileNameToUrl.isEmpty()) {
            q.setData(replacePlaceholders(q.getData(), fileNameToUrl));
        }
        
        Question saved = questionRepository.save(q);
        return mapToResponse(saved);
    }

    private String replacePlaceholders(String jsonData, Map<String, String> fileNameToUrl) {
        try {
            System.out.println("[QuestionBankService] Replacing placeholders in data. Mapping: " + fileNameToUrl);
            Map<String, Object> dataMap = objectMapper.readValue(jsonData, Map.class);
            boolean modified = replaceRecursive(dataMap, fileNameToUrl);
            if (modified) {
                String result = objectMapper.writeValueAsString(dataMap);
                System.out.println("[QuestionBankService] Placeholders resolved successfully.");
                return result;
            }
            System.out.println("[QuestionBankService] No placeholders were matched/replaced.");
            return jsonData;
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
                        String fileName = StringUtils.cleanPath(s.substring(7));
                        if (fileNameToUrl.containsKey(fileName)) {
                            entry.setValue(fileNameToUrl.get(fileName));
                            modified = true;
                        } else {
                            System.out.println("[QuestionBankService] No match for placeholder filename: [" + fileName + "]");
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
                        String fileName = StringUtils.cleanPath(s.substring(7));
                        if (fileNameToUrl.containsKey(fileName)) {
                            list.set(i, fileNameToUrl.get(fileName));
                            modified = true;
                        } else {
                            System.out.println("[QuestionBankService] No match for placeholder filename in list: [" + fileName + "]");
                        }
                    }
                } else if (val instanceof Map || val instanceof List) {
                    if (replaceRecursive(val, fileNameToUrl)) modified = true;
                }
            }
        }
        return modified;
    }

    private Map<String, String> handleMediaUpload(Question q, List<MultipartFile> mediaFiles, List<String> retainedMediaUrls, String originalUrls) {
        Map<String, String> fileNameToUrl = new java.util.HashMap<>();
        
        // finalUrls will hold the URLs we want to save
        List<String> finalUrls = new ArrayList<>();
        List<String> finalTypes = new ArrayList<>();

        // 1. Process Retained Media
        if (retainedMediaUrls != null && !retainedMediaUrls.isEmpty()) {
            for (String url : retainedMediaUrls) {
                finalUrls.add(url);
                // Lookup MIME type for retained files
                String mimeType = mediaFileRepository.findByStoredPath(url.trim())
                        .map(MediaFile::getMimeType)
                        .orElse("application/octet-stream");
                finalTypes.add(mimeType);
            }
        }

        // 2. Identify and delete removed files (comparing vs what was ON DISK before this request)
        List<String> oldUrls = (originalUrls != null && !originalUrls.isEmpty()) 
                ? Arrays.asList(originalUrls.split(",")) 
                : new ArrayList<>();
        
        List<String> retainedList = retainedMediaUrls != null ? retainedMediaUrls : new ArrayList<>();

        for (String url : oldUrls) {
            // If it's not in the retained list, delete it
            if (!retainedList.contains(url)) {
                deleteFileFromStorage(url);
            }
        }

        // 3. Process New Media Files
        if (mediaFiles != null && !mediaFiles.isEmpty()) {
            for (MultipartFile media : mediaFiles) {
                if (!media.isEmpty()) {
                    try {
                        String originalFilename = StringUtils.cleanPath(media.getOriginalFilename());
                        String extension = getExtension(originalFilename);
                        String subDir = getSubDir(extension, "questions");
                        
                        Path uploadPath = Paths.get(baseUploadDir, subDir).toAbsolutePath().normalize();
                        if (!Files.exists(uploadPath)) {
                            Files.createDirectories(uploadPath);
                        }

                        String uniqueFilename = UUID.randomUUID().toString() + extension;
                        Path filePath = uploadPath.resolve(uniqueFilename);
                        Files.copy(media.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

                        String servedUrl = "/media/" + subDir + "/" + uniqueFilename;
                        finalUrls.add(servedUrl);
                        finalTypes.add(media.getContentType());
                        fileNameToUrl.put(originalFilename, servedUrl);
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

    private String getSubDir(String extension, String context) {
        if (extension.matches("(?i)\\.(mp4|avi|mov|mkv)"))
            return "videos";
        if (extension.matches("(?i)\\.(mp3|wav|ogg)"))
            return "audio";
        if (extension.matches("(?i)\\.(jpg|jpeg|png|gif|webp)")) {
            if (StringUtils.hasText(context) && (context.equalsIgnoreCase("questions") || context.equalsIgnoreCase("answers"))) {
                return context.toLowerCase();
            }
            return "answers";
        }
        return "documents";
    }

    private String getExtension(String filename) {
        int dotIndex = filename.lastIndexOf('.');
        return (dotIndex == -1) ? "" : filename.substring(dotIndex);
    }

    private void deleteFileFromStorage(String mediaUrl) {
        if (mediaUrl == null || !mediaUrl.startsWith("/media/"))
            return;

        try {
            // e.g. /media/answers/abc.jpg -> answers/abc.jpg
            String relativePath = mediaUrl.substring(7); 
            Path filePath = Paths.get(baseUploadDir).resolve(relativePath).toAbsolutePath().normalize();
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
