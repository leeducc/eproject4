package com.groupone.backend.features.feedback;

import com.groupone.backend.features.feedback.dto.FeedbackDetailDto;
import com.groupone.backend.features.feedback.dto.FeedbackDto;
import com.groupone.backend.features.feedback.dto.FeedbackMessageDto;
import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.features.identity.auth.EmailService;
import com.groupone.backend.features.media.MediaFile;
import com.groupone.backend.features.media.MediaService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class FeedbackService {

    private final FeedbackRepository feedbackRepository;
    private final FeedbackMessageRepository messageRepository;
    private final UserRepository userRepository;
    private final EmailService emailService;
    private final MediaService mediaService;

    @Transactional
    public FeedbackDto createFeedback(Long userId, String title, String textContent, MultipartFile image) throws IOException {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        String imageUrl = null;
        if (image != null && !image.isEmpty()) {
            MediaFile uploadedFile = mediaService.uploadFile(image, userId, "feedback");
            imageUrl = uploadedFile.getStoredPath();
        }

        Feedback feedback = Feedback.builder()
                .user(user)
                .title(title)
                .textContent(textContent)
                .imageUrl(imageUrl)
                .status(FeedbackStatus.PENDING)
                .build();

        Feedback savedFeedback = feedbackRepository.save(feedback);
        log.info("Feedback {} created by user {}", savedFeedback.getId(), userId);

        return toDto(savedFeedback);
    }

    public Page<FeedbackDto> getAllFeedbacks(Pageable pageable) {
        return feedbackRepository.findAllByOrderByCreatedAtDesc(pageable)
                .map(this::toDto);
    }

    public FeedbackDetailDto getFeedbackDetails(Long id) {
        Feedback feedback = feedbackRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Feedback not found"));
        
        List<FeedbackMessage> messages = messageRepository.findByFeedbackIdOrderByCreatedAtAsc(id);
        
        return FeedbackDetailDto.builder()
                .feedback(toDto(feedback))
                .messages(messages.stream().map(this::toMessageDto).collect(Collectors.toList()))
                .build();
    }

    @Transactional
    public FeedbackDto replyToFeedback(Long feedbackId, Long adminId, String textContent) {
        Feedback feedback = feedbackRepository.findById(feedbackId)
                .orElseThrow(() -> new RuntimeException("Feedback not found"));

        FeedbackMessage message = FeedbackMessage.builder()
                .feedback(feedback)
                .senderId(adminId)
                .isAdmin(true)
                .textContent(textContent)
                .build();

        messageRepository.save(message);

        feedback.setStatus(FeedbackStatus.RESOLVED);
        feedbackRepository.save(feedback);

        log.info("Admin {} replied to feedback {}", adminId, feedbackId);

        try {
            String toEmail = feedback.getUser().getEmail();
            emailService.sendFeedbackResponseEmail(toEmail, feedback.getTitle(), textContent);
        } catch (Exception e) {
            log.error("Failed to send feedback reply email to user: {}", e.getMessage());
        }

        return toDto(feedback);
    }

    private FeedbackDto toDto(Feedback feedback) {
        String fullName = feedback.getUser().getProfile() != null ? feedback.getUser().getProfile().getFullName() : "N/A";
        return FeedbackDto.builder()
                .id(feedback.getId())
                .userId(feedback.getUser().getId())
                .userEmail(feedback.getUser().getEmail())
                .userFullName(fullName)
                .title(feedback.getTitle())
                .textContent(feedback.getTextContent())
                .imageUrl(feedback.getImageUrl())
                .status(feedback.getStatus())
                .createdAt(feedback.getCreatedAt())
                .build();
    }

    private FeedbackMessageDto toMessageDto(FeedbackMessage message) {
        return FeedbackMessageDto.builder()
                .id(message.getId())
                .senderId(message.getSenderId())
                .isAdmin(message.isAdmin())
                .textContent(message.getTextContent())
                .createdAt(message.getCreatedAt())
                .build();
    }
}
