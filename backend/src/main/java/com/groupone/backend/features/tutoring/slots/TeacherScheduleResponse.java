package com.groupone.backend.features.tutoring.slots;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TeacherScheduleResponse {
    private Long teacherId;
    private String fullName;
    private String bio;
    private String avatar;
    private Double averageRating;
    private List<TeacherSlot> availableSlots;
}
