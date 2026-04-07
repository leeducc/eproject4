package com.groupone.backend.features.tutoring.slots;

import lombok.Data;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonFormat;

@Data
public class CreateSlotRequest {
    @JsonFormat(pattern = "HH:mm dd/MM/yyyy")
    private LocalDateTime startTime;
    @JsonFormat(pattern = "HH:mm dd/MM/yyyy")
    private LocalDateTime endTime;
    private int durationMinutes = 30;
}
