package com.groupone.backend.features.tutoring.slots;

import com.groupone.backend.features.identity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tutoring/slots")
@RequiredArgsConstructor
public class TeacherSlotController {

    private final TeacherSlotService slotService;

    
    @PostMapping("/teacher/bulk")
    public ResponseEntity<List<TeacherSlot>> createBulkSlots(
            @AuthenticationPrincipal User teacher,
            @RequestBody CreateSlotRequest request) {
        
        List<TeacherSlot> slots = slotService.createBulkSlots(
                teacher.getId(), 
                request.getStartTime(), 
                request.getEndTime(), 
                request.getDurationMinutes());
        return ResponseEntity.ok(slots);
    }

    @GetMapping("/teacher/all")
    public ResponseEntity<List<TeacherSlot>> getTeacherSlots(@AuthenticationPrincipal User teacher) {
        return ResponseEntity.ok(slotService.getSlotsByTeacher(teacher.getId()));
    }

    @DeleteMapping("/teacher/{slotId}")
    public ResponseEntity<Void> deleteSlot(@PathVariable Long slotId) {
        slotService.deleteSlot(slotId);
        return ResponseEntity.noContent().build();
    }

    
    @GetMapping("/student/available/{teacherId}")
    public ResponseEntity<List<TeacherSlot>> getAvailableSlots(@PathVariable Long teacherId) {
        return ResponseEntity.ok(slotService.getAvailableSlotsByTeacher(teacherId));
    }

    @PostMapping("/student/book/{slotId}")
    public ResponseEntity<TeacherSlot> bookSlot(
            @AuthenticationPrincipal User student,
            @PathVariable Long slotId) {
        return ResponseEntity.ok(slotService.bookSlot(student.getId(), slotId));
    }

    @GetMapping("/available-teachers")
    public ResponseEntity<List<TeacherScheduleResponse>> getAvailableTeachers() {
        return ResponseEntity.ok(slotService.getAvailableTeachersWithSchedules());
    }
}
