package com.groupone.backend.features.tutoring.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TutoringQueueMessage {
    private String type; // STUDENT_JOIN_QUEUE, TEACHER_ONLINE, MATCH_FOUND, STUDENT_ACCEPT_MATCH, ERROR
    private Long studentId;
    private Long teacherId;
    private Long sessionId;
    private Integer position;
    private Long ewtMinutes; // Estimated Wait Time in minutes
    private String message;
}
