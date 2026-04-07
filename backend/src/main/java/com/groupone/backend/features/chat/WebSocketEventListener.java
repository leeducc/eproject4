package com.groupone.backend.features.chat;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.features.tutoring.TutoringQueueService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectedEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Component
@RequiredArgsConstructor
@Slf4j
public class WebSocketEventListener {

    private final UserRepository userRepository;
    private final SimpMessagingTemplate messagingTemplate;
    private final TutoringQueueService tutoringQueueService;

    @EventListener
    public void handleWebSocketConnectedListener(SessionConnectedEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String email = headerAccessor.getUser() != null ? headerAccessor.getUser().getName() : null;
        
        if (email != null) {
            updateUserStatus(email, true);
            broadcastUserStatus(email, true);
            log.info("[WebSocket] User online (Connected): {}", email);
        } else {
            log.warn("[WebSocket] Connected event received but no user principal found");
        }
    }

    @EventListener
    public void handleWebSocketDisconnectListener(SessionDisconnectEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String email = headerAccessor.getUser() != null ? headerAccessor.getUser().getName() : null;

        if (email != null) {
            userRepository.findByEmail(email).ifPresent(user -> {
                tutoringQueueService.removeUserFromQueue(user.getId());
            });
            updateUserStatus(email, false);
            broadcastUserStatus(email, false);
            log.info("[WebSocket] User disconnected: {}", email);
        }
    }

    private void updateUserStatus(String email, boolean isOnline) {
        Optional<User> userOptional = userRepository.findByEmail(email);
        userOptional.ifPresent(user -> {
            user.setOnline(isOnline);
            user.setLastActiveAt(LocalDateTime.now());
            userRepository.save(user);
        });
    }

    private void broadcastUserStatus(String email, boolean isOnline) {
        userRepository.findByEmail(email).ifPresent(user -> {
            Map<String, Object> status = new HashMap<>();
            status.put("userId", user.getId());
            status.put("isOnline", isOnline);
            messagingTemplate.convertAndSend("/topic/user-status", status);
        });
    }
}
