package com.groupone.backend.features.tutoring;

import com.groupone.backend.features.tutoring.dto.TutoringQueueMessage;
import com.groupone.backend.features.identity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
@Slf4j
public class TutoringWebSocketController {

    private final TutoringQueueService queueService;

    @MessageMapping("/tutoring/queue/join")
    public void joinQueue(Authentication authentication) {
        User user = (User) authentication.getPrincipal();
        log.info("WebSocket request: Student {} joining tutoring queue", user.getId());
        queueService.addStudentToQueue(user.getId());
    }

    @MessageMapping("/tutoring/teacher/ready")
    public void teacherReady(Authentication authentication) {
        User user = (User) authentication.getPrincipal();
        log.info("WebSocket request: Teacher {} reporting ready", user.getId());
        queueService.teacherReportingReady(user.getId());
    }

    @MessageMapping("/tutoring/student/accept")
    public void acceptMatch(Authentication authentication, @Payload TutoringQueueMessage message) {
        User user = (User) authentication.getPrincipal();
        log.info("WebSocket request: Student {} accepting match with Teacher {}", user.getId(), message.getTeacherId());
        
        // Use a default coin amount for tutoring (e.g., 50 coins for 30 minutes)
        // This could be made dynamic later or passed from frontend if validated
        int defaultCoinAmount = 50; 
        
        queueService.acceptMatch(user.getId(), message.getTeacherId(), defaultCoinAmount);
    }
}
