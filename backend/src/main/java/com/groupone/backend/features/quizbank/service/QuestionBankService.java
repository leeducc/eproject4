package com.groupone.backend.features.quizbank.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.groupone.backend.features.quizbank.dto.*;
import com.groupone.backend.features.quizbank.entity.*;
import com.groupone.backend.features.quizbank.enums.*;
import com.groupone.backend.features.quizbank.repository.*;
import com.groupone.backend.features.quizbank.util.ExcelQuestionMapper;
import com.groupone.backend.features.media.MediaFileRepository;
import com.groupone.backend.features.media.MediaFile;
import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;
import lombok.extern.slf4j.Slf4j;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Slf4j
public class QuestionBankService {

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private QuestionGroupRepository questionGroupRepository;

    @Autowired
    private QuestionHistoryRepository questionHistoryRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private MediaFileRepository mediaFileRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private ExcelService excelService;

    @Autowired
    private ExcelQuestionMapper excelQuestionMapper;

    @Autowired
    private TagService tagService;

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
            Long authorId,
            int limit) {
        log.info("[QuestionBankService] getQuestionsPaginated - skill: {}, type: {}, difficulty: {}, search: {}, lastSeenId: {}, authorId: {}, limit: {}", 
                 skill, type, difficulty, search, lastSeenId, authorId, limit);
            
        List<QuestionResponse> allResponses = new ArrayList<>();

        // 1. Fetch Groups if type is COMPREHENSION or ALL
        if (type == null || type == QuestionType.COMPREHENSION) {
            List<QuestionGroup> groups = questionGroupRepository.findAll().stream()
                .filter(g -> (skill == null || g.getSkill() == skill))
                .filter(g -> (difficulty == null || g.getDifficultyBand() == difficulty))
                .filter(g -> (authorId == null || g.getAuthorId().equals(authorId)))
                .filter(g -> (search == null || g.getTitle().toLowerCase().contains(search.toLowerCase()) || (g.getContent() != null && g.getContent().toLowerCase().contains(search.toLowerCase()))))
                .collect(Collectors.toList());
            
            allResponses.addAll(groups.stream().map(this::mapGroupToResponse).collect(Collectors.toList()));
            log.info("[QuestionBankService] Found {} groups", groups.size());
        }

        // 2. Fetch Questions if type is NOT COMPREHENSION or ALL
        if (type == null || type != QuestionType.COMPREHENSION) {
            List<Question> questions = questionRepository.findPaginated(
                    skill != null ? skill.name() : null,
                    type != null ? type.name() : null,
                    difficulty != null ? difficulty.name() : null,
                    search,
                    lastSeenId,
                    authorId,
                    limit
            );
            allResponses.addAll(questions.stream().map(this::mapToResponse).collect(Collectors.toList()));
            log.info("[QuestionBankService] Found {} questions", questions.size());
        }

        // Simple sorting for now - standalone questions after groups or by ID
        allResponses.sort((a, b) -> b.getId().compareTo(a.getId()));

        int toIndex = Math.min(allResponses.size(), limit);
        List<QuestionResponse> finalResponses = allResponses.subList(0, toIndex);

        Long nextCursor = null;
        boolean hasMore = allResponses.size() > limit;
        if (!finalResponses.isEmpty()) {
            nextCursor = finalResponses.get(finalResponses.size() - 1).getId();
        }

        return PaginatedResponse.<QuestionResponse>builder()
                .items(finalResponses)
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

        // Set author from Security Context
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof User) {
            q.setAuthorId(((User) principal).getId());
        }
        
        Question saved = questionRepository.save(q);
        recordHistory(saved, "CREATED");
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

        // Maintain original creator, but if it's null (old data) set it to the current user
        if (q.getAuthorId() == null) {
            Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
            if (principal instanceof User) {
                q.setAuthorId(((User) principal).getId());
            }
        }
        
        Question saved = questionRepository.save(q);
        recordHistory(saved, "UPDATED");
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

    private void recordHistory(Question question, String action) {
        try {
            Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
            Long userId = null;
            if (principal instanceof User) {
                userId = ((User) principal).getId();
            } else {
                userId = 1L;
                log.warn("[QuestionBankService] No user found in security context. Using default userId 1 for history recording.");
            }

            QuestionResponse currentSnapshot = mapToResponse(question);
            String snapshotJson = objectMapper.writeValueAsString(currentSnapshot);
            String changesJson = null;

            if ("UPDATED".equals(action)) {
                // Try to find the previous history record to compute diff
                Page<QuestionHistory> lastHistories = questionHistoryRepository.findByQuestionIdOrderByCreatedAtDesc(
                    question.getId(), PageRequest.of(0, 1));
                
                if (!lastHistories.isEmpty()) {
                    QuestionHistory lastHistory = lastHistories.getContent().get(0);
                    QuestionResponse previousSnapshot = objectMapper.readValue(lastHistory.getSnapshot(), QuestionResponse.class);
                    Map<String, Object> changes = computeChanges(previousSnapshot, currentSnapshot);
                    if (!changes.isEmpty()) {
                        changesJson = objectMapper.writeValueAsString(changes);
                    }
                }
            }

            QuestionHistory history = QuestionHistory.builder()
                    .questionId(question.getId())
                    .editorId(userId)
                    .action(action)
                    .snapshot(snapshotJson)
                    .changes(changesJson)
                    .build();
            questionHistoryRepository.save(history);
            log.info("[QuestionBankService] Recorded {} history for question ID: {}", action, question.getId());
        } catch (Exception e) {
            log.error("[QuestionBankService] Failed to record history: {}", e.getMessage());
        }
    }

    private Map<String, Object> computeChanges(QuestionResponse oldVer, QuestionResponse newVer) {
        Map<String, Object> changes = new HashMap<>();

        if (!Objects.equals(oldVer.getInstruction(), newVer.getInstruction())) {
            changes.put("instruction", Map.of("from", Objects.toString(oldVer.getInstruction(), ""), "to", Objects.toString(newVer.getInstruction(), "")));
        }
        if (!Objects.equals(oldVer.getExplanation(), newVer.getExplanation())) {
            changes.put("explanation", Map.of("from", Objects.toString(oldVer.getExplanation(), ""), "to", Objects.toString(newVer.getExplanation(), "")));
        }
        if (!Objects.equals(oldVer.getDifficultyBand(), newVer.getDifficultyBand())) {
            changes.put("difficultyBand", Map.of("from", Objects.toString(oldVer.getDifficultyBand(), ""), "to", Objects.toString(newVer.getDifficultyBand(), "")));
        }
        if (!Objects.equals(oldVer.getIsPremiumContent(), newVer.getIsPremiumContent())) {
            changes.put("isPremiumContent", Map.of("from", oldVer.getIsPremiumContent(), "to", newVer.getIsPremiumContent()));
        }
        if (!Objects.equals(oldVer.getData(), newVer.getData())) {
            changes.put("data", Map.of("from", oldVer.getData(), "to", newVer.getData()));
        }

        return changes;
    }

    public List<QuestionHistoryResponse> getQuestionHistory(Long questionId) {
        List<QuestionHistory> histories = questionHistoryRepository.findByQuestionIdOrderByCreatedAtDesc(questionId);
        return histories.stream().map(h -> {
            String editorEmail = userRepository.findById(h.getEditorId())
                    .map(User::getEmail)
                    .orElse("unknown@eproject.com");
            return QuestionHistoryResponse.builder()
                    .id(h.getId())
                    .questionId(h.getQuestionId())
                    .editorId(h.getEditorId())
                    .editorEmail(editorEmail)
                    .action(h.getAction())
                    .snapshot(h.getSnapshot())
                    .changes(h.getChanges())
                    .createdAt(h.getCreatedAt())
                    .build();
        }).collect(Collectors.toList());
    }

    public void rollbackToVersion(Long historyId) {
        QuestionHistory history = questionHistoryRepository.findById(historyId)
                .orElseThrow(() -> new RuntimeException("History record not found"));

        Question question = questionRepository.findById(history.getQuestionId())
                .orElseThrow(() -> new RuntimeException("Question not found"));

        try {
            QuestionResponse snapshot = objectMapper.readValue(history.getSnapshot(), QuestionResponse.class);
            
            // Restore fields from snapshot
            question.setSkill(snapshot.getSkill());
            question.setType(snapshot.getType());
            question.setDifficultyBand(snapshot.getDifficultyBand());
            question.setIsPremiumContent(snapshot.getIsPremiumContent());
            question.setInstruction(snapshot.getInstruction());
            question.setExplanation(snapshot.getExplanation());
            
            if (snapshot.getData() != null) {
                question.setData(objectMapper.writeValueAsString(snapshot.getData()));
            }

            // Media mapping
            if (snapshot.getMediaUrls() != null && !snapshot.getMediaUrls().isEmpty()) {
                question.setMediaUrl(String.join(",", snapshot.getMediaUrls()));
            } else {
                question.setMediaUrl(null);
            }

            if (snapshot.getMediaTypes() != null && !snapshot.getMediaTypes().isEmpty()) {
                question.setMediaType(String.join(",", snapshot.getMediaTypes()));
            } else {
                question.setMediaType(null);
            }

            questionRepository.save(question);
            recordHistory(question, "ROLLBACK");
            log.info("[QuestionBankService] Rolled back question {} to history version {}", question.getId(), historyId);
        } catch (IOException e) {
            throw new RuntimeException("Failed to parse history snapshot", e);
        }
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
        
        // Enforce WRITING skill always uses ESSAY type
        if (req.getSkill() == SkillType.WRITING) {
            log.info("[QuestionBankService] Enforcing ESSAY type for WRITING skill. Previous type: {}", req.getType());
            q.setType(QuestionType.ESSAY);
        } else {
            q.setType(req.getType());
        }

        q.setDifficultyBand(req.getDifficultyBand());
        q.setIsPremiumContent(req.getIsPremiumContent());
        q.setInstruction(req.getInstruction());
        q.setExplanation(req.getExplanation());
        q.setAuthorId(req.getAuthorId());

        if (req.getGroupId() != null) {
            QuestionGroup group = new QuestionGroup();
            group.setId(req.getGroupId());
            q.setGroup(group);
        } else {
            q.setGroup(null);
        }

        if (q.getType() == QuestionType.ESSAY && q.getSkill() != SkillType.WRITING) {
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

        if (req.getTags() != null) {
            System.out.println("[QuestionBankService] Setting tags: " + req.getTags());
            q.setTags(new ArrayList<>(new LinkedHashSet<>(tagService.getOrCreateTags(req.getTags()))));
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
                .groupId(q.getGroup() != null ? q.getGroup().getId() : null)
                .authorId(q.getAuthorId())
                .isGroup(false)
                .tags(q.getTags() != null ? new ArrayList<>(q.getTags()) : new ArrayList<>())
                .build();
    }

    public QuestionResponse mapGroupToResponse(QuestionGroup g) {
        return QuestionResponse.builder()
                .id(g.getId())
                .skill(g.getSkill())
                .type(QuestionType.COMPREHENSION)
                .difficultyBand(g.getDifficultyBand())
                .instruction(g.getTitle())
                .mediaUrls(g.getMediaUrl() != null && !g.getMediaUrl().isEmpty()
                        ? Arrays.asList(g.getMediaUrl().split(","))
                        : new ArrayList<>())
                .mediaTypes(g.getMediaType() != null && !g.getMediaType().isEmpty()
                        ? Arrays.asList(g.getMediaType().split(","))
                        : new ArrayList<>())
                .data(Map.of(
                        "content", g.getContent() != null ? g.getContent() : "",
                        "questions", g.getQuestions() != null 
                            ? g.getQuestions().stream().map(this::mapToResponse).collect(Collectors.toList())
                            : new ArrayList<>()
                ))
                .isGroup(true)
                .childCount(g.getQuestions() != null ? g.getQuestions().size() : 0)
                .authorId(g.getAuthorId())
                .build();
    }

    public byte[] exportQuestions() throws IOException {
        List<Question> questions = questionRepository.findAll();
        List<QuestionGroup> groups = questionGroupRepository.findAll();
        return excelService.exportQuestionsToExcel(questions, groups);
    }

    @org.springframework.transaction.annotation.Transactional
    public void importQuestions(InputStream inputStream) throws IOException {
        List<Map<String, String>> rows = excelService.importQuestionsFromExcel(inputStream);
        Map<String, Long> excelIdToDbGroupId = new HashMap<>();

        // Pass 1: Handle PASSAGE rows
        for (Map<String, String> row : rows) {
            String rowType = row.get("row_type");
            if ("PASSAGE".equalsIgnoreCase(rowType)) {
                try {
                    String idStr = row.get("id");
                    QuestionGroup g = null;
                    if (idStr != null && !idStr.trim().isEmpty() && !idStr.startsWith("TEMP")) {
                        try {
                            Long id = Long.parseLong(idStr.trim());
                            g = questionGroupRepository.findById(id).orElse(null);
                        } catch (NumberFormatException ignored) {}
                    }
                    
                    if (g == null) g = new QuestionGroup();
                    
                    excelQuestionMapper.mapMapToGroup(row, g);
                    
                    // Set author
                    Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
                    if (principal instanceof User) {
                        g.setAuthorId(((User) principal).getId());
                    }

                    QuestionGroup saved = questionGroupRepository.save(g);
                    if (idStr != null && !idStr.trim().isEmpty()) {
                        excelIdToDbGroupId.put(idStr.trim(), saved.getId());
                    }
                } catch (Exception e) {
                    log.error("[QuestionBankService] Error processing PASSAGE row: {}. Error: {}", row, e.getMessage());
                }
            }
        }

        // Pass 2: Handle QUESTION rows
        for (Map<String, String> row : rows) {
            String rowType = row.get("row_type");
            if ("QUESTION".equalsIgnoreCase(rowType)) {
                try {
                    String idStr = row.get("id");
                    Question q = null;
                    if (idStr != null && !idStr.trim().isEmpty()) {
                        try {
                            Long id = Long.parseLong(idStr.trim());
                            q = questionRepository.findById(id).orElse(null);
                        } catch (NumberFormatException ignored) {}
                    }
                    
                    if (q == null) q = new Question();

                    excelQuestionMapper.mapMapToEntity(row, q);
                    
                    // Link to group if group_id is provided
                    String groupIdStr = row.get("group_id");
                    if (groupIdStr != null && !groupIdStr.trim().isEmpty()) {
                        Long dbGroupId = excelIdToDbGroupId.get(groupIdStr.trim());
                        if (dbGroupId == null) {
                            try {
                                dbGroupId = Long.parseLong(groupIdStr.trim());
                            } catch (NumberFormatException ignored) {}
                        }
                        
                        if (dbGroupId != null) {
                            QuestionGroup group = questionGroupRepository.findById(dbGroupId).orElse(null);
                            q.setGroup(group);
                        }
                    } else {
                        q.setGroup(null);
                    }

                    // Set author
                    Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
                    if (principal instanceof User) {
                        q.setAuthorId(((User) principal).getId());
                    }

                    Question saved = questionRepository.save(q);
                    recordHistory(saved, "IMPORTED");
                } catch (Exception e) {
                    log.error("[QuestionBankService] Error processing QUESTION row: {}. Error: {}", row, e.getMessage());
                }
            }
        }
    }
}
