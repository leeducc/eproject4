package com.groupone.backend.features.tutoring.slots;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TeacherSlotRepository extends JpaRepository<TeacherSlot, Long> {
    List<TeacherSlot> findAllByTeacherId(Long teacherId);
    List<TeacherSlot> findAllByTeacherIdAndStartTimeAfter(Long teacherId, LocalDateTime after);
    List<TeacherSlot> findAllByTeacherIdAndStatusOrderByStartTime(Long teacherId, SlotStatus status);
    List<TeacherSlot> findAllByStatusAndStartTimeBetween(SlotStatus status, LocalDateTime start, LocalDateTime end);
}
