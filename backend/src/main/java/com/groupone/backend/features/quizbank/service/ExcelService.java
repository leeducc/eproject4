package com.groupone.backend.features.quizbank.service;

import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.entity.QuestionGroup;
import com.groupone.backend.features.quizbank.util.ExcelQuestionMapper;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.*;

@Service
@Slf4j
public class ExcelService {

    private final ExcelQuestionMapper mapper;
    private static final String[] HEADERS = {
            "row_type", "id", "group_id", "skill", "type", "difficulty_band", "instruction", "explanation",
            "is_premium_content", "media_type", "media_url", "content",
            "question_prompt", "options_or_matches", "correct_answer"
    };

    public ExcelService(ExcelQuestionMapper mapper) {
        this.mapper = mapper;
    }

    public byte[] exportQuestionsToExcel(List<Question> questions, List<QuestionGroup> groups) throws IOException {
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet("Questions_and_Passages");

            // Header row
            Row headerRow = sheet.createRow(0);
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            for (int i = 0; i < HEADERS.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(HEADERS[i]);
                cell.setCellStyle(headerStyle);
            }

            // Data rows
            int rowIdx = 1;
            
            // First, export passages
            if (groups != null) {
                for (QuestionGroup g : groups) {
                    Row row = sheet.createRow(rowIdx++);
                    Map<String, Object> dataMap = mapper.mapGroupToMap(g);
                    fillRow(row, dataMap);
                }
            }

            // Then, export questions
            if (questions != null) {
                for (Question q : questions) {
                    Row row = sheet.createRow(rowIdx++);
                    Map<String, Object> dataMap = mapper.mapEntityToMap(q);
                    fillRow(row, dataMap);
                }
            }

            for (int i = 0; i < HEADERS.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(out);
            return out.toByteArray();
        }
    }

    private void fillRow(Row row, Map<String, Object> dataMap) {
        for (int i = 0; i < HEADERS.length; i++) {
            Object value = dataMap.get(HEADERS[i]);
            if (value != null) {
                row.createCell(i).setCellValue(value.toString());
            }
        }
    }

    public List<Map<String, String>> importQuestionsFromExcel(InputStream is) throws IOException {
        List<Map<String, String>> rows = new ArrayList<>();
        try (Workbook workbook = new XSSFWorkbook(is)) {
            Sheet sheet = workbook.getSheetAt(0);
            Row headerRow = sheet.getRow(0);
            if (headerRow == null) return rows;

            Map<Integer, String> headerMap = new HashMap<>();
            for (Cell cell : headerRow) {
                headerMap.put(cell.getColumnIndex(), cell.getStringCellValue());
            }

            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;

                Map<String, String> rowData = new HashMap<>();
                boolean isEmpty = true;
                for (int j = 0; j < HEADERS.length; j++) {
                    Cell cell = row.getCell(j);
                    String header = HEADERS[j];
                    String value = getCellValueAsString(cell);
                    if (value != null && !value.trim().isEmpty()) {
                        isEmpty = false;
                    }
                    rowData.put(header, value);
                }
                if (!isEmpty) {
                    rows.add(rowData);
                }
            }
        }
        return rows;
    }

    private String getCellValueAsString(Cell cell) {
        if (cell == null) return "";
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue();
            case NUMERIC:
                if (DateUtil.isCellDateFormatted(cell)) {
                    return cell.getDateCellValue().toString();
                }
                // Handle numeric ID or premium content (1/0)
                double numericValue = cell.getNumericCellValue();
                if (numericValue == (long) numericValue) {
                    return String.valueOf((long) numericValue);
                }
                return String.valueOf(numericValue);
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            case FORMULA:
                return cell.getCellFormula();
            case BLANK:
                return "";
            default:
                return "";
        }
    }
}
