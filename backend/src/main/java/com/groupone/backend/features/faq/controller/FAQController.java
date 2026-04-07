package com.groupone.backend.features.faq.controller;

import com.groupone.backend.features.faq.dto.FAQDto;
import com.groupone.backend.features.faq.service.FAQService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class FAQController {
    private final FAQService faqService;

    
    @GetMapping("/faqs")
    public ResponseEntity<List<FAQDto>> getPublicFAQs() {
        return ResponseEntity.ok(faqService.getActiveFAQs());
    }

    
    @GetMapping("/admin/faqs")
    public ResponseEntity<List<FAQDto>> getAllFAQs() {
        return ResponseEntity.ok(faqService.getAllFAQs());
    }

    @PostMapping("/admin/faqs")
    public ResponseEntity<FAQDto> createFAQ(@RequestBody FAQDto dto) {
        return ResponseEntity.ok(faqService.createFAQ(dto));
    }

    @PutMapping("/admin/faqs/{id}")
    public ResponseEntity<FAQDto> updateFAQ(@PathVariable Long id, @RequestBody FAQDto dto) {
        return ResponseEntity.ok(faqService.updateFAQ(id, dto));
    }

    @DeleteMapping("/admin/faqs/{id}")
    public ResponseEntity<Void> deleteFAQ(@PathVariable Long id) {
        faqService.deleteFAQ(id);
        return ResponseEntity.noContent().build();
    }
}
