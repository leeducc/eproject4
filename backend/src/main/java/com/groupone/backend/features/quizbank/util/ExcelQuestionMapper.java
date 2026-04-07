package com.groupone.backend.features.quizbank.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.entity.QuestionGroup;
import com.groupone.backend.features.quizbank.enums.DifficultyBand;
import com.groupone.backend.features.quizbank.enums.QuestionType;
import com.groupone.backend.features.quizbank.enums.SkillType;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.stream.Collectors;

@Component
@Slf4j
public class ExcelQuestionMapper {

    private final ObjectMapper objectMapper;

    public ExcelQuestionMapper(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    public Map<String, Object> mapEntityToMap(Question q) {
        Map<String, Object> map = new HashMap<>();
        map.put("row_type", "QUESTION");
        map.put("id", q.getId());
        map.put("group_id", q.getGroup() != null ? q.getGroup().getId() : "");
        map.put("skill", q.getSkill().name());
        map.put("type", q.getType().name());
        map.put("difficulty_band", q.getDifficultyBand().name());
        map.put("instruction", q.getInstruction());
        map.put("explanation", q.getExplanation());
        map.put("is_premium_content", q.getIsPremiumContent() ? 1 : 0);
        map.put("media_type", q.getMediaType());
        map.put("media_url", q.getMediaUrl());
        map.put("content", "");

        
        switch (q.getType()) {
            case MULTIPLE_CHOICE:
                mapMultipleChoiceToExcel(q, map);
                break;
            case MATCHING:
                mapMatchingToExcel(q, map);
                break;
            case FILL_BLANK:
                mapFillBlankToExcel(q, map);
                break;
            case ESSAY:
                mapEssayToExcel(q, map);
                break;
        }

        return map;
    }

    public Map<String, Object> mapGroupToMap(QuestionGroup g) {
        Map<String, Object> map = new HashMap<>();
        map.put("row_type", "PASSAGE");
        map.put("id", g.getId());
        map.put("group_id", "");
        map.put("skill", g.getSkill().name());
        map.put("type", "COMPREHENSION");
        map.put("difficulty_band", g.getDifficultyBand().name());
        map.put("instruction", g.getTitle());
        map.put("explanation", "");
        map.put("is_premium_content", 0);
        map.put("media_type", g.getMediaType());
        map.put("media_url", g.getMediaUrl());
        map.put("content", g.getContent());
        map.put("question_prompt", "");
        map.put("options_or_matches", "");
        map.put("correct_answer", "");
        return map;
    }

    public Question mapMapToEntity(Map<String, String> row, Question q) {
        log.info("[ExcelQuestionMapper] Mapping row to question: {}", row);
        
        q.setSkill(SkillType.valueOf(row.get("skill").trim().toUpperCase()));
        
        
        if (q.getSkill() == SkillType.WRITING) {
            log.info("[ExcelQuestionMapper] Enforcing ESSAY type for WRITING skill. Original row type: {}", row.get("type"));
            q.setType(QuestionType.ESSAY);
        } else {
            q.setType(QuestionType.valueOf(row.get("type").trim().toUpperCase()));
        }
        q.setDifficultyBand(DifficultyBand.valueOf(row.get("difficulty_band").trim().toUpperCase()));
        
        q.setInstruction(row.get("instruction"));
        q.setExplanation(row.get("explanation"));
        q.setIsPremiumContent("1".equals(row.get("is_premium_content")));
        q.setMediaType(row.get("media_type"));
        q.setMediaUrl(row.get("media_url"));

        String prompt = row.get("question_prompt");
        String options = row.get("options_or_matches");
        String answer = row.get("correct_answer");

        switch (q.getType()) {
            case MULTIPLE_CHOICE:
                mapExcelToMultipleChoice(q, prompt, options, answer);
                break;
            case MATCHING:
                mapExcelToMatching(q, prompt, options, answer);
                break;
            case FILL_BLANK:
                mapExcelToFillBlank(q, prompt, options, answer);
                break;
            case ESSAY:
                mapExcelToEssay(q, prompt, options, answer);
                break;
        }

        return q;
    }

    public QuestionGroup mapMapToGroup(Map<String, String> row, QuestionGroup g) {
        log.info("[ExcelQuestionMapper] Mapping row to group: {}", row);
        
        g.setSkill(SkillType.valueOf(row.get("skill").trim().toUpperCase()));
        g.setTitle(row.get("instruction")); 
        g.setContent(row.get("content"));
        g.setDifficultyBand(DifficultyBand.valueOf(row.get("difficulty_band").trim().toUpperCase()));
        g.setMediaType(row.get("media_type"));
        g.setMediaUrl(row.get("media_url"));
        
        return g;
    }

    

    private void mapMultipleChoiceToExcel(Question q, Map<String, Object> map) {
        try {
            Map<String, Object> data = objectMapper.readValue(q.getData(), Map.class);
            List<Map<String, Object>> optionsList = (List<Map<String, Object>>) data.get("options");
            List<String> correctIds = (List<String>) data.get("correct_ids");

            if (optionsList != null) {
                String optionsStr = optionsList.stream()
                        .map(opt -> opt.get("label").toString())
                        .collect(Collectors.joining(" | "));
                map.put("options_or_matches", optionsStr);

                if (correctIds != null && !correctIds.isEmpty()) {
                    String correctStr = optionsList.stream()
                            .filter(opt -> correctIds.contains(opt.get("id").toString()))
                            .map(opt -> opt.get("label").toString())
                            .collect(Collectors.joining(" | "));
                    map.put("correct_answer", correctStr);
                }
            }
            map.put("question_prompt", q.getInstruction()); 
        } catch (Exception e) {
            log.error("Error mapping MULTIPLE_CHOICE to Excel", e);
        }
    }

    private void mapExcelToMultipleChoice(Question q, String prompt, String options, String answer) {
        if (prompt != null && !prompt.trim().isEmpty()) {
            q.setInstruction(prompt);
        }

        List<String> optLabels = splitAndTrim(options);
        List<String> ansLabels = splitAndTrim(answer);

        List<Map<String, Object>> optionsList = new ArrayList<>();
        List<String> correctIds = new ArrayList<>();

        for (int i = 0; i < optLabels.size(); i++) {
            String label = optLabels.get(i);
            String id = String.valueOf(i + 1);
            Map<String, Object> optMap = new HashMap<>();
            optMap.put("id", id);
            optMap.put("label", label);
            optionsList.add(optMap);

            if (ansLabels.contains(label)) {
                correctIds.add(id);
            }
        }

        Map<String, Object> data = new HashMap<>();
        data.put("options", optionsList);
        data.put("correct_ids", correctIds);
        data.put("multiple_select", correctIds.size() > 1);
        data.put("answer_with_image", false);

        saveData(q, data);
    }

    

    private void mapMatchingToExcel(Question q, Map<String, Object> map) {
        try {
            Map<String, Object> data = objectMapper.readValue(q.getData(), Map.class);
            List<Map<String, Object>> leftItems = (List<Map<String, Object>>) data.get("left_items");
            List<Map<String, Object>> rightItems = (List<Map<String, Object>>) data.get("right_items");
            Map<String, String> solution = (Map<String, String>) data.get("solution");

            if (leftItems != null) {
                map.put("question_prompt", leftItems.stream()
                        .map(item -> item.get("text").toString())
                        .collect(Collectors.joining(" | ")));
            }
            if (rightItems != null) {
                map.put("options_or_matches", rightItems.stream()
                        .map(item -> item.get("text").toString())
                        .collect(Collectors.joining(" | ")));
            }
            if (solution != null && leftItems != null && rightItems != null) {
                List<String> pairs = new ArrayList<>();
                for (Map.Entry<String, String> entry : solution.entrySet()) {
                    String leftText = findTextById(leftItems, entry.getKey());
                    String rightText = findTextById(rightItems, entry.getValue());
                    pairs.add(leftText + "-" + rightText);
                }
                map.put("correct_answer", String.join(" | ", pairs));
            }
        } catch (Exception e) {
            log.error("Error mapping MATCHING to Excel", e);
        }
    }

    private String findTextById(List<Map<String, Object>> items, String id) {
        return items.stream()
                .filter(item -> item.get("id").toString().equals(id))
                .map(item -> item.get("text").toString())
                .findFirst()
                .orElse(id);
    }

    private void mapExcelToMatching(Question q, String leftStr, String rightStr, String solutionStr) {
        List<String> leftTexts = splitAndTrim(leftStr);
        List<String> rightTexts = splitAndTrim(rightStr);
        List<String> solutionPairs = splitAndTrim(solutionStr);

        List<Map<String, Object>> leftItems = new ArrayList<>();
        for (int i = 0; i < leftTexts.size(); i++) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", "L" + i);
            item.put("text", leftTexts.get(i));
            leftItems.add(item);
        }

        List<Map<String, Object>> rightItems = new ArrayList<>();
        for (int i = 0; i < rightTexts.size(); i++) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", "R" + i);
            item.put("text", rightTexts.get(i));
            rightItems.add(item);
        }

        Map<String, String> solution = new HashMap<>();
        for (String pair : solutionPairs) {
            String[] parts = pair.split("-");
            if (parts.length == 2) {
                String leftText = parts[0].trim();
                String rightText = parts[1].trim();

                String leftId = findIdByText(leftItems, leftText);
                String rightId = findIdByText(rightItems, rightText);

                if (leftId != null && rightId != null) {
                    solution.put(leftId, rightId);
                }
            }
        }

        Map<String, Object> data = new HashMap<>();
        data.put("left_items", leftItems);
        data.put("right_items", rightItems);
        data.put("solution", solution);

        saveData(q, data);
    }

    private String findIdByText(List<Map<String, Object>> items, String text) {
        return items.stream()
                .filter(item -> item.get("text").toString().equalsIgnoreCase(text))
                .map(item -> item.get("id").toString())
                .findFirst()
                .orElse(null);
    }

    

    private void mapFillBlankToExcel(Question q, Map<String, Object> map) {
        try {
            Map<String, Object> data = objectMapper.readValue(q.getData(), Map.class);
            map.put("question_prompt", data.get("template"));
            Map<String, Map<String, Object>> blanks = (Map<String, Map<String, Object>>) data.get("blanks");
            if (blanks != null) {
                
                List<String> sortedKeys = blanks.keySet().stream()
                        .sorted(Comparator.comparingInt(k -> Integer.parseInt(k.replaceAll("\\D", ""))))
                        .collect(Collectors.toList());

                String answers = sortedKeys.stream()
                        .map(k -> ((List<String>) blanks.get(k).get("correct")).get(0))
                        .collect(Collectors.joining(" | "));
                map.put("correct_answer", answers);
            }
            List<String> pool = (List<String>) data.get("answer_pool");
            if (pool != null) {
                map.put("options_or_matches", String.join(" | ", pool));
            }
        } catch (Exception e) {
            log.error("Error mapping FILL_BLANK to Excel", e);
        }
    }

    private void mapExcelToFillBlank(Question q, String template, String pool, String answers) {
        Map<String, Object> data = new HashMap<>();
        data.put("template", template);

        List<String> ansList = splitAndTrim(answers);
        Map<String, Object> blanks = new HashMap<>();
        for (int i = 0; i < ansList.size(); i++) {
            Map<String, Object> blankData = new HashMap<>();
            String ans = ansList.get(i);
            blankData.put("correct", Collections.singletonList(ans));
            blankData.put("max_words", ans.split("\\s+").length);
            blanks.put("blank" + (i + 1), blankData);
        }
        data.put("blanks", blanks);

        List<String> poolList = splitAndTrim(pool);
        if (!poolList.isEmpty()) {
            data.put("answer_pool", poolList);
        }

        saveData(q, data);
    }

    

    private void mapEssayToExcel(Question q, Map<String, Object> map) {
        map.put("question_prompt", q.getInstruction());
        map.put("correct_answer", q.getExplanation());
    }

    private void mapExcelToEssay(Question q, String prompt, String options, String answer) {
        if (prompt != null && !prompt.trim().isEmpty()) {
            q.setInstruction(prompt);
        }
        if (answer != null && !answer.trim().isEmpty()) {
            q.setExplanation(answer);
        }
        
        
        
        Map<String, Object> data = new HashMap<>();
        data.put("type", "ESSAY");
        saveData(q, data);
    }

    

    private List<String> splitAndTrim(String str) {
        if (str == null || str.trim().isEmpty()) {
            return Collections.emptyList();
        }
        return Arrays.stream(str.split("\\|"))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toList());
    }

    private void saveData(Question q, Map<String, Object> data) {
        try {
            q.setData(objectMapper.writeValueAsString(data));
        } catch (JsonProcessingException e) {
            log.error("Error serializing data for question", e);
            throw new RuntimeException("Error converting data to JSON", e);
        }
    }
}
