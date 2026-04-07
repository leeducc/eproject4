package com.groupone.backend.features.tutoring;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.features.tutoring.dto.TutoringQueueMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class TutoringQueueService {

    private final SimpMessagingTemplate messagingTemplate;
    private final TutoringSessionService sessionService;
    private final UserRepository userRepository;

    // Students waiting for a teacher
    private final ConcurrentLinkedQueue<Long> studentQueue = new ConcurrentLinkedQueue<>();
    // Teachers online and ready to accept match
    private final ConcurrentLinkedQueue<Long> availableTeachers = new ConcurrentLinkedQueue<>();
    // Temporary matches awaiting student confirmation
    private final Map<Long, Long> pendingMatches = new ConcurrentHashMap<>(); // teacherId -> studentId
    // Timestamp when student joined queue for EWT calculation
    private final Map<Long, LocalDateTime> studentStartTime = new ConcurrentHashMap<>();
    
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

    public void addStudentToQueue(Long studentId) {
        if (!studentQueue.contains(studentId)) {
            log.info("Student {} joining the queue", studentId);
            studentQueue.add(studentId);
            studentStartTime.put(studentId, LocalDateTime.now());
        }
        
        checkAndMatch();
        notifyPosition(studentId);
    }

    public void teacherReportingReady(Long teacherId) {
        log.info("Teacher {} reporting ready for new students", teacherId);
        if (!availableTeachers.contains(teacherId)) {
            availableTeachers.add(teacherId);
        }
        checkAndMatch();
    }

    private synchronized void checkAndMatch() {
        while (!studentQueue.isEmpty() && !availableTeachers.isEmpty()) {
            Long studentId = studentQueue.poll();
            Long teacherId = availableTeachers.poll();
            
            if (studentId == null || teacherId == null) break;

            log.info("Match found! Student {} and Teacher {}", studentId, teacherId);
            pendingMatches.put(teacherId, studentId);
            
            // Notify both of a match
            TutoringQueueMessage matchMsg = TutoringQueueMessage.builder()
                    .type("MATCH_FOUND")
                    .studentId(studentId)
                    .teacherId(teacherId)
                    .message("Match found! Student has 60 seconds to accept.")
                    .build();
            
            messagingTemplate.convertAndSend("/topic/tutoring-queue/student/" + studentId, matchMsg);
            messagingTemplate.convertAndSend("/topic/tutoring-queue/teacher/" + teacherId, matchMsg);

            // Set 60-second timeout for acceptance
            scheduler.schedule(() -> handleMatchTimeout(teacherId, studentId), 60, TimeUnit.SECONDS);
        }
    }

    private void handleMatchTimeout(Long teacherId, Long studentId) {
        if (pendingMatches.get(teacherId) != null && pendingMatches.get(teacherId).equals(studentId)) {
            log.info("Match timeout for Student {} and Teacher {}. Putting teacher back in available pool.", studentId, teacherId);
            pendingMatches.remove(teacherId);
            availableTeachers.add(teacherId);
            
            messagingTemplate.convertAndSend("/topic/tutoring-queue/student/" + studentId, 
                TutoringQueueMessage.builder().type("MATCH_TIMEOUT").message("You didn't accept in time. Exiting queue.").build());
            messagingTemplate.convertAndSend("/topic/tutoring-queue/teacher/" + teacherId, 
                TutoringQueueMessage.builder().type("MATCH_TIMEOUT").message("Student didn't accept. You are back in queue.").build());
            
            checkAndMatch();
        }
    }

    public void acceptMatch(Long studentId, Long teacherId, int coinAmount) {
        if (pendingMatches.get(teacherId) != null && pendingMatches.get(teacherId).equals(studentId)) {
            log.info("Student {} accepted match with Teacher {}", studentId, teacherId);
            pendingMatches.remove(teacherId);
            
            User student = userRepository.findById(studentId).orElse(null);
            User teacher = userRepository.findById(teacherId).orElse(null);
            
            if (student != null && teacher != null) {
                // Start session in DB
                TutoringSession session = sessionService.requestSession(student, teacher, coinAmount);
                sessionService.startSession(session.getId());

                notifyAcceptance(studentId, teacherId, session.getId());
            } else {
                availableTeachers.add(teacherId);
                log.error("Internal error: Student or Teacher not found during acceptance.");
            }
        }
    }

    private void notifyAcceptance(Long studentId, Long teacherId, Long sessionId) {
        TutoringQueueMessage msg = TutoringQueueMessage.builder()
                .type("MATCH_ACCEPTED")
                .studentId(studentId)
                .teacherId(teacherId)
                .sessionId(sessionId)
                .message("Session started perfectly! Ready to call.")
                .build();
        
        messagingTemplate.convertAndSend("/topic/tutoring-queue/student/" + studentId, msg);
        messagingTemplate.convertAndSend("/topic/tutoring-queue/teacher/" + teacherId, msg);
    }

    private void notifyPosition(Long studentId) {
        List<Long> currentQueue = new ArrayList<>(studentQueue);
        int position = currentQueue.indexOf(studentId) + 1;
        long ewt = calculateBasicEWT(position);

        messagingTemplate.convertAndSend("/topic/tutoring-queue/student/" + studentId, 
            TutoringQueueMessage.builder()
                .type("JOIN_CONFIRMED")
                .position(position)
                .ewtMinutes(ewt)
                .message("You are at position " + position + " in queue.")
                .build());
    }

    private long calculateBasicEWT(int position) {
        if (position <= 0) return 0;
        int activeTeachersCount = Math.max(1, availableTeachers.size() + pendingMatches.size());
        // Basic EWT: Position * 30 mins / teachers
        return (long) position * 30 / activeTeachersCount;
    }

    public void removeUserFromQueue(Long userId) {
        log.info("Removing user {} from tutoring queue structures (if present)", userId);
        studentQueue.remove(userId);
        studentStartTime.remove(userId);
        availableTeachers.remove(userId);
        // We don't remove from pendingMatches automatically here as we have the 60s timeout mechanism
        // but we could mark the match as VOIDED if necessary.
    }
}
