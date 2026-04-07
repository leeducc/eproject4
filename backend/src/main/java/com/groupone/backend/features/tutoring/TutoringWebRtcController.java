package com.groupone.backend.features.tutoring;

import com.groupone.backend.features.tutoring.dto.WebRtcSignalMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
@Slf4j
public class TutoringWebRtcController {

    private final SimpMessagingTemplate messagingTemplate;

    /**
     * Handles WebRTC signaling (OFFER, ANSWER, ICE-CANDIDATE)
     * Routes the signal to the specific target user identifying their session.
     */
    @MessageMapping("/tutoring/rtc/signal")
    public void processRtcSignal(@Payload WebRtcSignalMessage message) {
        log.info("[RTC Signaling] Type: {}, From: {}, To: {}", 
                 message.getType(), message.getFromUser(), message.getToUser());
        
        // This will send to /user/{toUser}/queue/rtc-signal
        messagingTemplate.convertAndSendToUser(
                message.getToUser(), 
                "/queue/rtc-signal", 
                message
        );
    }
}
