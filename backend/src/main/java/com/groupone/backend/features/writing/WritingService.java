package com.groupone.backend.features.writing;

import com.groupone.backend.features.writing.dto.EssaySubmissionRequest;
import com.groupone.backend.features.writing.dto.EssaySubmissionResponse;
import com.groupone.backend.features.writing.dto.TopicResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class WritingService {

    private final WritingTopicRepository topicRepository;
    private final WritingSubmissionRepository submissionRepository;
    private final OllamaService ollamaService;

    public List<TopicResponse> getAllTopics() {
        log.info("Fetching all writing topics");
        return topicRepository.findAll().stream()
                .map(TopicResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public EssaySubmissionResponse submitEssay(EssaySubmissionRequest request) {
        log.info("Submitting essay for topicId {}", request.getTopicId());
        
        WritingTopic topic = topicRepository.findById(request.getTopicId())
                .orElseThrow(() -> new RuntimeException("Topic not found"));
                
        // Initialize submission
        WritingSubmission submission = WritingSubmission.builder()
                .topic(topic)
                .content(request.getContent())
                .gradingType(request.getGradingType())
                .createdAt(LocalDateTime.now())
                .build();

        // Perform AI Grading if requested
        if (request.getGradingType() == GradingType.AI) {
            log.info("Initiating AI Grading for submission on topic '{}'", topic.getTitle());
            OllamaService.OllamaGradingResult result = ollamaService.gradeEssay(topic.getDescription(), request.getContent());
            submission.setScore(result.score());
            submission.setAiFeedback(result.feedback());
        }
                
        WritingSubmission savedSubmission = submissionRepository.save(submission);
        log.info("Successfully saved essay submission with ID {}", savedSubmission.getId());
        
        return EssaySubmissionResponse.fromEntity(savedSubmission);
    }
}
