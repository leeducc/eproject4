package com.groupone.backend.features.vocabulary;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.features.quizbank.dto.PaginatedResponse;
import com.opencsv.CSVReader;
import com.opencsv.exceptions.CsvValidationException;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class VocabularyService {

    private final VocabularyRepository vocabularyRepository;
    private final VocabularyHistoryRepository vocabularyHistoryRepository;
    private final VocabularyPracticeAiContentRepository practiceRepository;
    private final VocabularyPracticeHistoryRepository practiceHistoryRepository;
    private final VocabularyFavoriteRepository favoriteRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper;

    private static final String CSV_DIR = "uploads/dictionary";
    private static final String WORDS_FILE = "oxford-5k.csv";
    private static final String PHRASES_FILE = "oxford-phrase.csv";

    @PostConstruct
    public void init() {
        if (vocabularyRepository.count() > 0) {
            log.info("Vocabulary database already seeded. Skipping CSV load.");
            return;
        }

        log.info("Initializing VocabularyService - Seeding database from CSV data...");
        loadCsv(Paths.get(CSV_DIR, WORDS_FILE), "word");
        loadCsv(Paths.get(CSV_DIR, PHRASES_FILE), "phrase");
        log.info("Seeding complete. Total entries: {}", vocabularyRepository.count());
    }

    private void loadCsv(Path path, String type) {
        log.info("Loading {} from CSV: {}", type, path);
        try (CSVReader reader = new CSVReader(new FileReader(path.toFile()))) {
            String[] line;
            String[] header = reader.readNext(); 
            
            if (header == null) {
                log.warn("CSV file at {} is empty.", path);
                return;
            }

            List<VocabularyEntity> batch = new ArrayList<>();
            while ((line = reader.readNext()) != null) {
                if (line.length < 2) continue;

                String wordText = line[0].trim();
                String level = line[1].trim().toLowerCase();
                String pos = line.length > 2 ? line[2].trim() : "";
                String defUrl = line.length > 3 ? line[3].trim() : "";
                String voiceUrl = line.length > 4 ? line[4].trim() : "";

                VocabularyEntity entity = VocabularyEntity.builder()
                        .word(wordText)
                        .type(type)
                        .level(level)
                        .levelGroup(mapLevelToGroup(level))
                        .pos(pos)
                        .definitionUrl(defUrl)
                        .voiceUrl(voiceUrl)
                        .build();
                
                batch.add(entity);
                
                if (batch.size() >= 100) {
                    vocabularyRepository.saveAll(batch);
                    batch.clear();
                }
            }
            if (!batch.isEmpty()) {
                vocabularyRepository.saveAll(batch);
            }
        } catch (IOException | CsvValidationException e) {
            log.error("Error reading CSV file at {}: {}", path, e.getMessage());
        }
    }

    private String mapLevelToGroup(String level) {
        return switch (level) {
            case "a1", "a2" -> "0-4";
            case "b1", "b2" -> "5-6";
            case "c1" -> "7-8";
            case "c2" -> "9";
            default -> "unknown";
        };
    }

    public PaginatedResponse<VocabularyItem> getVocabularyPaginated(
            String type, 
            String levelGroup, 
            String search,
            Long lastSeenId,
            int limit) {
            
        String queryType = "phrases".equalsIgnoreCase(type) ? "phrase" : "word";
        
        List<VocabularyEntity> entities = vocabularyRepository.findPaginated(
                queryType,
                levelGroup != null && !levelGroup.isEmpty() ? levelGroup : null,
                search != null && !search.isEmpty() ? search : null,
                lastSeenId,
                limit
        );

        List<VocabularyItem> items = entities.stream()
                .map(this::mapToItem)
                .collect(Collectors.toList());

        
        try {
            Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
            if (principal instanceof User) {
                Long userId = ((User) principal).getId();
                Set<Long> favoriteIds = favoriteRepository.findAllByUserId(userId).stream()
                        .map(f -> f.getVocabulary().getId())
                        .collect(Collectors.toSet());
                items.forEach(item -> item.setIsFavorite(favoriteIds.contains(item.getId())));
            }
        } catch (Exception e) {
            
        }

        Long nextCursor = null;
        boolean hasMore = entities.size() >= limit;
        if (!entities.isEmpty()) {
            nextCursor = entities.get(entities.size() - 1).getId();
        }

        return PaginatedResponse.<VocabularyItem>builder()
                .items(items)
                .nextCursor(nextCursor)
                .hasMore(hasMore)
                .build();
    }

    public VocabularyItem createVocabulary(VocabularyItem item) {
        VocabularyEntity entity = VocabularyEntity.builder()
                .word(item.getWord())
                .type(item.getType())
                .level(item.getLevel())
                .levelGroup(mapLevelToGroup(item.getLevel()))
                .pos(item.getPos())
                .definitionUrl(item.getDefinitionUrl())
                .voiceUrl(item.getVoiceUrl())
                .phonetic(item.getPhonetic())
                .isPremium(item.getIsPremium() != null ? item.getIsPremium() : false)
                .build();
        
        VocabularyEntity saved = vocabularyRepository.save(entity);
        recordHistory(saved, "CREATED");
        return mapToItem(saved);
    }

    public VocabularyItem updateVocabulary(Long id, VocabularyItem item) {
        VocabularyEntity entity = vocabularyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vocabulary not found"));
        
        entity.setWord(item.getWord());
        entity.setType(item.getType());
        entity.setLevel(item.getLevel());
        entity.setLevelGroup(mapLevelToGroup(item.getLevel()));
        entity.setPos(item.getPos());
        entity.setDefinitionUrl(item.getDefinitionUrl());
        entity.setVoiceUrl(item.getVoiceUrl());
        entity.setPhonetic(item.getPhonetic());
        entity.setIsPremium(item.getIsPremium() != null ? item.getIsPremium() : false);

        
        if (item.getDefinition() != null) entity.setDefinition(item.getDefinition());
        try {
            if (item.getExamples() != null) entity.setExamplesJson(objectMapper.writeValueAsString(item.getExamples()));
            if (item.getSynonyms() != null) entity.setSynonymsJson(objectMapper.writeValueAsString(item.getSynonyms()));
        } catch (JsonProcessingException e) {
            log.error("Failed to serialize AI content for vocabulary {}: {}", id, e.getMessage());
        }
        
        VocabularyEntity saved = vocabularyRepository.save(entity);
        recordHistory(saved, "UPDATED");
        return mapToItem(saved);
    }

    public VocabularyItem getVocabularyById(Long id) {
        VocabularyEntity entity = vocabularyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vocabulary not found"));
        return mapToItem(entity);
    }

    public void deleteVocabulary(Long id) {
        vocabularyRepository.deleteById(id);
    }

    public void recordHistory(VocabularyEntity entity, String action) {
        try {
            Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
            Long userId = (principal instanceof User) ? ((User) principal).getId() : 1L;

            String snapshotJson = objectMapper.writeValueAsString(mapToItem(entity));
            String changesJson = null;

            if ("UPDATED".equals(action)) {
                List<VocabularyHistory> lastHistories = vocabularyHistoryRepository.findByVocabularyIdOrderByCreatedAtDesc(entity.getId());
                if (!lastHistories.isEmpty()) {
                    VocabularyHistory lastHistory = lastHistories.get(0);
                    VocabularyItem previousSnapshot = objectMapper.readValue(lastHistory.getSnapshot(), VocabularyItem.class);
                    Map<String, Object> changes = computeChanges(previousSnapshot, mapToItem(entity));
                    if (!changes.isEmpty()) {
                        changesJson = objectMapper.writeValueAsString(changes);
                    }
                }
            }

            VocabularyHistory history = VocabularyHistory.builder()
                    .vocabularyId(entity.getId())
                    .editorId(userId)
                    .action(action)
                    .snapshot(snapshotJson)
                    .changes(changesJson)
                    .build();
            vocabularyHistoryRepository.save(history);
        } catch (Exception e) {
            log.error("Failed to record history for vocabulary {}: {}", entity.getId(), e.getMessage());
        }
    }

    private Map<String, Object> computeChanges(VocabularyItem oldVer, VocabularyItem newVer) {
        Map<String, Object> changes = new HashMap<>();
        if (!Objects.equals(oldVer.getWord(), newVer.getWord())) changes.put("word", Map.of("from", oldVer.getWord(), "to", newVer.getWord()));
        if (!Objects.equals(oldVer.getLevel(), newVer.getLevel())) changes.put("level", Map.of("from", oldVer.getLevel(), "to", newVer.getLevel()));
        if (!Objects.equals(oldVer.getPos(), newVer.getPos())) changes.put("pos", Map.of("from", oldVer.getPos(), "to", newVer.getPos()));
        if (!Objects.equals(oldVer.getPhonetic(), newVer.getPhonetic())) changes.put("phonetic", Map.of("from", oldVer.getPhonetic(), "to", newVer.getPhonetic()));
        if (!Objects.equals(oldVer.getIsPremium(), newVer.getIsPremium())) changes.put("isPremium", Map.of("from", oldVer.getIsPremium(), "to", newVer.getIsPremium()));
        return changes;
    }

    public void rollbackToVersion(Long historyId) {
        VocabularyHistory history = vocabularyHistoryRepository.findById(historyId)
                .orElseThrow(() -> new RuntimeException("History record not found"));
        VocabularyEntity entity = vocabularyRepository.findById(history.getVocabularyId())
                .orElseThrow(() -> new RuntimeException("Vocabulary not found"));

        try {
            VocabularyItem snapshot = objectMapper.readValue(history.getSnapshot(), VocabularyItem.class);
            entity.setWord(snapshot.getWord());
            entity.setLevel(snapshot.getLevel());
            entity.setLevelGroup(snapshot.getLevelGroup());
            entity.setPos(snapshot.getPos());
            entity.setDefinitionUrl(snapshot.getDefinitionUrl());
            entity.setVoiceUrl(snapshot.getVoiceUrl());
            entity.setPhonetic(snapshot.getPhonetic());
            entity.setIsPremium(snapshot.getIsPremium() != null ? snapshot.getIsPremium() : false);

            vocabularyRepository.save(entity);
            recordHistory(entity, "ROLLBACK");
        } catch (IOException e) {
            throw new RuntimeException("Failed to parse history snapshot", e);
        }
    }

    public List<VocabularyHistoryDTO> getWordHistory(Long vocabularyId) {
        return vocabularyHistoryRepository.findHistoryWithEditorName(vocabularyId);
    }

    public List<VocabularyPracticeAiContentEntity> getPracticeByWord(String word) {
        return practiceRepository.findAllByWord(word);
    }

    public void updatePractice(Long id, String jsonContent) {
        VocabularyPracticeAiContentEntity entity = practiceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Practice content not found"));
        entity.setJsonContent(jsonContent);
        entity.setVersion(entity.getVersion() != null ? entity.getVersion() + 1 : 1);
        practiceRepository.save(entity);
        recordPracticeHistory(entity, "UPDATED");
    }

    public void deletePractice(Long id) {
        practiceRepository.deleteById(id);
    }

    public VocabularyPracticeAiContentEntity createPractice(String word, PracticeQuiz practice) {
        try {
            VocabularyPracticeAiContentEntity entity = VocabularyPracticeAiContentEntity.builder()
                    .word(word)
                    .quizType(practice.getType())
                    .jsonContent(objectMapper.writeValueAsString(practice))
                    .version(1)
                    .build();
            VocabularyPracticeAiContentEntity saved = practiceRepository.save(entity);
            recordPracticeHistory(saved, "CREATED_MANUALLY");
            return saved;
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialize practice content", e);
        }
    }

    public void recordPracticeHistory(VocabularyPracticeAiContentEntity entity, String action) {
        try {
            Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
            Long userId = (principal instanceof User) ? ((User) principal).getId() : 1L;

            VocabularyPracticeHistory history = VocabularyPracticeHistory.builder()
                    .practiceId(entity.getId())
                    .editorId(userId)
                    .action(action)
                    .snapshot(entity.getJsonContent())
                    .version(entity.getVersion())
                    .build();
            practiceHistoryRepository.save(history);
        } catch (Exception e) {
            log.error("Failed to record history for practice {}: {}", entity.getId(), e.getMessage());
        }
    }

    public void rollbackPracticeToVersion(Long historyId) {
        VocabularyPracticeHistory history = practiceHistoryRepository.findById(historyId)
                .orElseThrow(() -> new RuntimeException("History record not found"));
        VocabularyPracticeAiContentEntity entity = practiceRepository.findById(history.getPracticeId())
                .orElseThrow(() -> new RuntimeException("Practice content not found"));

        entity.setJsonContent(history.getSnapshot());
        entity.setVersion(entity.getVersion() != null ? entity.getVersion() + 1 : 1);
        practiceRepository.save(entity);
        recordPracticeHistory(entity, "ROLLBACK");
    }

    public List<VocabularyPracticeHistoryDTO> getPracticeHistory(Long practiceId) {
        return practiceHistoryRepository.findHistoryWithEditorName(practiceId);
    }

    private VocabularyItem mapToItem(VocabularyEntity entity) {
        VocabularyItem item = VocabularyItem.builder()
                .id(entity.getId())
                .word(entity.getWord())
                .type(entity.getType())
                .level(entity.getLevel())
                .levelGroup(entity.getLevelGroup())
                .pos(entity.getPos())
                .definitionUrl(entity.getDefinitionUrl())
                .voiceUrl(entity.getVoiceUrl())
                .definition(entity.getDefinition())
                .examples(safeReadList(entity.getExamplesJson()))
                .synonyms(safeReadList(entity.getSynonymsJson()))
                .phonetic(entity.getPhonetic())
                .isPremium(entity.getIsPremium())
                .build();
        
        
        try {
            Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
            if (principal instanceof User) {
                item.setIsFavorite(favoriteRepository.existsByUserIdAndVocabularyId(((User) principal).getId(), entity.getId()));
            }
        } catch (Exception e) {}
        
        return item;
    }

    @jakarta.transaction.Transactional
    public boolean toggleFavorite(Long vocabularyId) {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (!(principal instanceof User)) throw new RuntimeException("User not authenticated");
        User user = (User) principal;

        Optional<VocabularyFavoriteEntity> existing = favoriteRepository.findByUserIdAndVocabularyId(user.getId(), vocabularyId);
        if (existing.isPresent()) {
            favoriteRepository.delete(existing.get());
            return false;
        } else {
            VocabularyEntity vocabulary = vocabularyRepository.findById(vocabularyId)
                    .orElseThrow(() -> new RuntimeException("Vocabulary not found"));
            favoriteRepository.save(VocabularyFavoriteEntity.builder()
                    .user(user)
                    .vocabulary(vocabulary)
                    .build());
            return true;
        }
    }

    public List<VocabularyItem> getFavorites() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (!(principal instanceof User)) return Collections.emptyList();
        Long userId = ((User) principal).getId();

        return favoriteRepository.findAllByUserId(userId).stream()
                .map(f -> {
                    VocabularyItem item = mapToItem(f.getVocabulary());
                    item.setIsFavorite(true);
                    return item;
                })
                .collect(Collectors.toList());
    }

    public byte[] generateSampleExcel() {
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet("Vocabulary Sample");
            
            
            Row headerRow = sheet.createRow(0);
            String[] columns = {"word", "type", "level", "pos", "definitionUrl", "voiceUrl"};
            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
                CellStyle style = workbook.createCellStyle();
                Font font = workbook.createFont();
                font.setBold(true);
                style.setFont(font);
                cell.setCellStyle(style);
            }

            
            Row sampleRow = sheet.createRow(1);
            sampleRow.createCell(0).setCellValue("ubiquitous");
            sampleRow.createCell(1).setCellValue("word");
            sampleRow.createCell(2).setCellValue("c2");
            sampleRow.createCell(3).setCellValue("adjective");
            sampleRow.createCell(4).setCellValue("https://example.com/def/ubiquitous");
            sampleRow.createCell(5).setCellValue("https://example.com/audio/ubiquitous.mp3");

            workbook.write(out);
            return out.toByteArray();
        } catch (IOException e) {
            log.error("Failed to generate sample Excel: {}", e.getMessage());
            throw new RuntimeException("Excel generation failed");
        }
    }

    public int importFromExcel(MultipartFile file) {
        int count = 0;
        try (InputStream is = file.getInputStream(); Workbook workbook = new XSSFWorkbook(is)) {
            Sheet sheet = workbook.getSheetAt(0);
            Iterator<Row> rows = sheet.iterator();
            
            if (!rows.hasNext()) return 0;
            Row headerRow = rows.next(); 
            
            List<VocabularyEntity> batch = new ArrayList<>();
            while (rows.hasNext()) {
                Row currentRow = rows.next();
                
                String word = getCellValueAsString(currentRow.getCell(0));
                if (word == null || word.isEmpty()) continue;

                String type = getCellValueAsString(currentRow.getCell(1));
                String level = getCellValueAsString(currentRow.getCell(2));
                String pos = getCellValueAsString(currentRow.getCell(3));
                String defUrl = getCellValueAsString(currentRow.getCell(4));
                String voiceUrl = getCellValueAsString(currentRow.getCell(5));

                VocabularyEntity entity = VocabularyEntity.builder()
                        .word(word)
                        .type(type != null ? type.toLowerCase() : "word")
                        .level(level != null ? level.toLowerCase() : "a1")
                        .levelGroup(mapLevelToGroup(level != null ? level.toLowerCase() : "a1"))
                        .pos(pos)
                        .definitionUrl(defUrl)
                        .voiceUrl(voiceUrl)
                        .build();
                
                batch.add(entity);
                count++;

                if (batch.size() >= 50) {
                    vocabularyRepository.saveAll(batch);
                    batch.clear();
                }
            }
            if (!batch.isEmpty()) {
                vocabularyRepository.saveAll(batch);
            }
        } catch (IOException e) {
            log.error("Failed to import Excel: {}", e.getMessage());
            throw new RuntimeException("Excel import failed: " + e.getMessage());
        }
        return count;
    }

    private String getCellValueAsString(Cell cell) {
        if (cell == null) return null;
        return switch (cell.getCellType()) {
            case STRING -> cell.getStringCellValue().trim();
            case NUMERIC -> String.valueOf((int) cell.getNumericCellValue());
            case BOOLEAN -> String.valueOf(cell.getBooleanCellValue());
            default -> null;
        };
    }

    private List<String> safeReadList(String json) {
        if (json == null || json.isEmpty()) return new ArrayList<>();
        try {
            return objectMapper.readValue(json, new com.fasterxml.jackson.core.type.TypeReference<List<String>>() {});
        } catch (JsonProcessingException e) {
            return new ArrayList<>();
        }
    }
}
