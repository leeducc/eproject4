package com.groupone.backend.features.moderation.service;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.moderation.entity.Report;
import com.groupone.backend.features.moderation.entity.ReportNotification;
import com.groupone.backend.features.moderation.enums.ReportStatus;
import com.groupone.backend.features.moderation.enums.ReportedItemType;
import com.groupone.backend.features.moderation.repository.ReportNotificationRepository;
import com.groupone.backend.features.moderation.repository.ReportRepository;
import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.repository.QuestionRepository;
import com.groupone.backend.features.vocabulary.VocabularyEntity;
import com.groupone.backend.features.vocabulary.VocabularyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
public class ModerationService {
    private final ReportRepository reportRepository;
    private final ReportNotificationRepository notificationRepository;
    private final QuestionRepository questionRepository;
    private final VocabularyRepository vocabularyRepository;

    private static final Pattern SPAM_PATTERN = Pattern.compile("(fuck|shit|damn|spam|test|abcde)", Pattern.CASE_INSENSITIVE);

    @Transactional
    public Report submitReport(User reporter, ReportedItemType itemType, Long itemId, String reason) {
        
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime oneMinuteAgo = now.minusMinutes(1);
        LocalDateTime oneHourAgo = now.minusHours(1);

        long reportsLastMinute = reportRepository.countByReporterIdAndCreatedAtAfter(reporter.getId(), oneMinuteAgo);
        if (reportsLastMinute >= 3) {
            throw new RuntimeException("Too many reports. Please wait a minute.");
        }

        long reportsLastHour = reportRepository.countByReporterIdAndCreatedAtAfter(reporter.getId(), oneHourAgo);
        if (reportsLastHour >= 10) {
            throw new RuntimeException("Hourly report limit reached.");
        }

        
        reportRepository.findByReporterIdAndItemTypeAndItemIdAndStatus(reporter.getId(), itemType, itemId, ReportStatus.NEW)
                .ifPresent(r -> {
                    throw new RuntimeException("You have already reported this item. Our team is reviewing it.");
                });

        
        ReportStatus status = ReportStatus.NEW;
        if (SPAM_PATTERN.matcher(reason).find()) {
            status = ReportStatus.SPAM;
        }

        Report report = Report.builder()
                .reporter(reporter)
                .itemType(itemType)
                .itemId(itemId)
                .reason(reason)
                .status(status)
                .build();

        return reportRepository.save(report);
    }

    @Transactional
    public Report resolveReport(Long reportId, String adminResponse, boolean disableContent) {
        Report report = reportRepository.findById(reportId)
                .orElseThrow(() -> new RuntimeException("Report not found"));

        if (report.getStatus() == ReportStatus.RESOLVED) {
            throw new RuntimeException("Report already resolved");
        }

        report.setStatus(ReportStatus.RESOLVED);
        report.setAdminResponse(adminResponse);

        if (disableContent) {
            if (report.getItemType() == ReportedItemType.QUESTION) {
                Question question = questionRepository.findById(report.getItemId())
                        .orElseThrow(() -> new RuntimeException("Question not found"));
                question.setIsActive(false);
                questionRepository.save(question);
            } else if (report.getItemType() == ReportedItemType.VOCABULARY) {
                VocabularyEntity vocab = vocabularyRepository.findById(report.getItemId())
                        .orElseThrow(() -> new RuntimeException("Vocabulary not found"));
                vocab.setIsActive(false);
                vocabularyRepository.save(vocab);
            }
        }

        
        ReportNotification notification = ReportNotification.builder()
                .user(report.getReporter())
                .report(report)
                .message("Your report for " + report.getItemType() + " #" + report.getItemId() + " has been resolved. Admin feedback: " + adminResponse)
                .build();
        notificationRepository.save(notification);

        return reportRepository.save(report);
    }

    @Transactional(readOnly = true)
    public List<Report> getReports(ReportStatus status) {
        return reportRepository.findByStatusOrderByCreatedAtDesc(status);
    }

    @Transactional(readOnly = true)
    public List<ReportNotification> getNotifications(Long userId) {
        return notificationRepository.findByUserIdAndIsReadFalseOrderByCreatedAtDesc(userId);
    }

    @Transactional
    public void markNotificationRead(Long notificationId) {
        notificationRepository.findById(notificationId).ifPresent(n -> {
            n.setIsRead(true);
            notificationRepository.save(n);
        });
    }

    @Transactional
    public void dismissSpam(Long reportId) {
        Report report = reportRepository.findById(reportId)
                .orElseThrow(() -> new RuntimeException("Report not found"));
        report.setStatus(ReportStatus.SPAM);
        reportRepository.save(report);
    }
}
