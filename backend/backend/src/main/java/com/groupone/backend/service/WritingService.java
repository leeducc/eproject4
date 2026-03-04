package com.groupone.backend.service;

import com.groupone.backend.dto.EssaySubmissionRequest;
import com.groupone.backend.dto.EssaySubmissionResponse;
import com.groupone.backend.dto.TopicDto;
import com.groupone.backend.model.EssaySubmission;
import com.groupone.backend.model.WritingTopic;
import com.groupone.backend.repository.EssaySubmissionRepository;
import com.groupone.backend.repository.WritingTopicRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WritingService {

    private final WritingTopicRepository topicRepository;
    private final EssaySubmissionRepository submissionRepository;
    private final OllamaService ollamaService;

    public List<TopicDto> getAllTopics() {
        return topicRepository.findAll().stream()
                .map(topic -> new TopicDto(
                        topic.getId(),
                        topic.getTitle(),
                        topic.getDescription(),
                        topic.getHint(),
                        topic.getImageUrl(),
                        topic.getAudioUrl()))
                .collect(Collectors.toList());
    }

    @Transactional
    public EssaySubmissionResponse submitEssay(EssaySubmissionRequest request) {
        WritingTopic topic = topicRepository.findById(request.getTopicId())
                .orElseThrow(() -> new RuntimeException("Topic not found"));

        EssaySubmission submission = new EssaySubmission();
        submission.setTopic(topic);
        submission.setContent(request.getContent());
        submission.setGradingType(request.getGradingType());

        if (request.getGradingType() == EssaySubmission.GradingType.AI) {
            String feedback = ollamaService.generateGradingFeedback(topic.getTitle(), request.getContent());
            submission.setAiFeedback(feedback);
            // Optionally parse score from feedback, left null for now
        }

        EssaySubmission savedSubmission = submissionRepository.save(submission);

        return EssaySubmissionResponse.builder()
                .id(savedSubmission.getId())
                .topic(new TopicDto(
                        topic.getId(),
                        topic.getTitle(),
                        topic.getDescription(),
                        topic.getHint(),
                        topic.getImageUrl(),
                        topic.getAudioUrl()))
                .content(savedSubmission.getContent())
                .gradingType(savedSubmission.getGradingType())
                .aiFeedback(savedSubmission.getAiFeedback())
                .score(savedSubmission.getScore())
                .createdAt(savedSubmission.getCreatedAt())
                .build();
    }
}
