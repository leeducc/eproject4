package com.groupone.backend.features.tutoring.slots;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
@Slf4j
public class SlotReminderTask {

    private final TeacherSlotRepository slotRepository;
    private final SimpMessagingTemplate messagingTemplate;
    private final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");

    @Scheduled(fixedRate = 60000) // Every 1 minute
    public void scanAndRemindSlots() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime threshold = now.plusMinutes(5);

        log.debug("[ReminderTask] Scanning for slots between {} and {}", now, threshold);

        List<TeacherSlot> startingSoon = slotRepository.findAllByStatusAndStartTimeBetween(
                SlotStatus.BOOKED, now, threshold);

        for (TeacherSlot slot : startingSoon) {
            String timeStr = slot.getStartTime().format(formatter);
            String message = "Buổi học của bạn sẽ bắt đầu lúc " + timeStr;

            Map<String, Object> payload = Map.of(
                    "type", "REMINDER",
                    "message", message,
                    "slotId", slot.getId().toString()
            );

            // Send to Teacher
            log.info("[ReminderTask] Sending reminder to Teacher ID: {}", slot.getTeacherId());
            messagingTemplate.convertAndSendToUser(
                    slot.getTeacherId().toString(), 
                    "/topic/notifications", 
                    payload);

            // Send to Student
            if (slot.getStudentId() != null) {
                log.info("[ReminderTask] Sending reminder to Student ID: {}", slot.getStudentId());
                messagingTemplate.convertAndSendToUser(
                        slot.getStudentId().toString(), 
                        "/topic/notifications", 
                        payload);
            }
        }
    }
}
