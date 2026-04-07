package com.groupone.backend.features.tutoring.slots;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.features.tutoring.TutoringReviewRepository;
import com.groupone.backend.shared.enums.UserRole;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class TeacherSlotService {

    private final TeacherSlotRepository slotRepository;
    private final UserRepository userRepository;
    private final TutoringReviewRepository reviewRepository;

    @Transactional
    public List<TeacherSlot> createBulkSlots(Long teacherId, LocalDateTime start, LocalDateTime end, int durationMinutes) {
        log.info("[SlotService] Bulk creating slots for teacher: {} from {} to {} with duration: {}m", 
                 teacherId, start, end, durationMinutes);
        List<TeacherSlot> existingSlots = slotRepository.findAllByTeacherId(teacherId);
        
        List<TeacherSlot> createdSlots = new ArrayList<>();
        LocalDateTime current = start;

        while (current.plusMinutes(durationMinutes).isBefore(end) || current.plusMinutes(durationMinutes).isEqual(end)) {
            LocalDateTime proposedStart = current;
            LocalDateTime proposedEnd = current.plusMinutes(durationMinutes);

            // Check overlap
            boolean isOverlapping = existingSlots.stream().anyMatch(existing -> 
                existing.getStartTime().isBefore(proposedEnd) && proposedStart.isBefore(existing.getEndTime())
            );

            if (isOverlapping) {
                log.warn("[SlotService] Proposed slot {} - {} overlaps with existing schedule for teacher: {}", 
                         proposedStart, proposedEnd, teacherId);
                throw new RuntimeException("Lịch dạy tại khung giờ " + proposedStart.toLocalTime() + " - " + 
                                           proposedEnd.toLocalTime() + " đã bị trùng với lịch trước đó.");
            }

            TeacherSlot slot = TeacherSlot.builder()
                    .teacherId(teacherId)
                    .startTime(proposedStart)
                    .endTime(proposedEnd)
                    .status(SlotStatus.AVAILABLE)
                    .build();
            createdSlots.add(slotRepository.save(slot));
            current = current.plusMinutes(durationMinutes);
        }

        return createdSlots;
    }

    public List<TeacherSlot> getSlotsByTeacher(Long teacherId) {
        return slotRepository.findAllByTeacherId(teacherId);
    }

    public List<TeacherSlot> getAvailableSlotsByTeacher(Long teacherId) {
        return slotRepository.findAllByTeacherIdAndStatusOrderByStartTime(teacherId, SlotStatus.AVAILABLE);
    }

    @Transactional
    public TeacherSlot bookSlot(Long studentId, Long slotId) {
        log.info("[SlotService] Student: {} booking slot: {}", studentId, slotId);
        TeacherSlot slot = slotRepository.findById(slotId)
                .orElseThrow(() -> new RuntimeException("Slot not found"));
        
        if (slot.getStatus() != SlotStatus.AVAILABLE) {
            throw new RuntimeException("Slot is no longer available: " + slot.getStatus());
        }

        slot.setStudentId(studentId);
        slot.setStatus(SlotStatus.BOOKED);
        return slotRepository.save(slot);
    }

    @Transactional
    public void deleteSlot(Long slotId) {
        slotRepository.deleteById(slotId);
    }

    public List<TeacherScheduleResponse> getAvailableTeachersWithSchedules() {
        log.info("[SlotService] Fetching all available teachers and their schedules");
        
        List<User> teachers = userRepository.findByRoleAndSearch(UserRole.TEACHER, null);

        return teachers.stream().map(teacher -> {
            List<TeacherSlot> slots = slotRepository.findAllByTeacherIdOrderByStartTime(teacher.getId());
            
            Double avgRating = reviewRepository.getAverageRatingByTeacherId(teacher.getId());
            if (avgRating == null) avgRating = 0.0;

            String bio = teacher.getProfile() != null ? teacher.getProfile().getBio() : "";
            String avatar = teacher.getProfile() != null ? teacher.getProfile().getAvatarUrl() : "";
            String fullName = teacher.getProfile() != null ? teacher.getProfile().getFullName() : teacher.getEmail();

            return TeacherScheduleResponse.builder()
                    .teacherId(teacher.getId())
                    .fullName(fullName)
                    .bio(bio)
                    .avatar(avatar)
                    .averageRating(avgRating)
                    .availableSlots(slots)
                    .build();
        }).collect(Collectors.toList());
    }
}
