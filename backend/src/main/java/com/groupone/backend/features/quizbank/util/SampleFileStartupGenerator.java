package com.groupone.backend.features.quizbank.util;

import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

@Component
@Slf4j
public class SampleFileStartupGenerator implements CommandLineRunner {

    private static final String FILE_PATH = "d:/project/eproject4/database/sample_questions.xlsx";

    @Override
    public void run(String... args) throws Exception {
        File file = new File(FILE_PATH);
        if (file.exists()) {
            log.info("[SampleFileStartupGenerator] Sample Excel file already exists at: {}", FILE_PATH);
            return;
        }

        log.info("[SampleFileStartupGenerator] Generating sample Excel file at: {}", FILE_PATH);
        generateSample(file);
    }

    private void generateSample(File file) throws IOException {
        String[] headers = {
            "id", "skill", "type", "difficulty_band", "instruction", "explanation",
            "is_premium_content", "media_type", "media_url",
            "question_prompt", "options_or_matches", "correct_answer"
        };

        try (Workbook workbook = new XSSFWorkbook(); FileOutputStream out = new FileOutputStream(file)) {
            Sheet sheet = workbook.createSheet("Sample Questions");
            Row headerRow = sheet.createRow(0);
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            Object[][] data = {
                {"", "VOCABULARY", "MULTIPLE_CHOICE", "BAND_0_4", "Choose synonym.", "", 0, "", "", "Synonym of Happy?", "Sad | Cheerful", "Cheerful"},
                {"", "READING", "MATCHING", "BAND_5_6", "Match sounds.", "", 1, "", "", "Cat | Dog", "Meow | Woof", "Cat-Meow | Dog-Woof"},
                {"", "WRITING", "FILL_BLANK", "BAND_7_8", "Prepositions.", "", 0, "", "", "The cat is [blank1] the mat.", "on", "on"},
                {"", "WRITING", "ESSAY", "BAND_9", "Climate essay.", "", 1, "", "", "Discuss climate change.", "", "Rubric: ..."}
            };

            for (int i = 0; i < data.length; i++) {
                Row row = sheet.createRow(i + 1);
                for (int j = 0; j < data[i].length; j++) {
                    row.createCell(j).setCellValue(data[i][j].toString());
                }
            }

            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(out);
            log.info("[SampleFileStartupGenerator] Sample Excel file created successfully.");
        }
    }
}
