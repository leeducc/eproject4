package com.groupone.backend.features.chat;

import com.groupone.backend.shared.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;

import java.util.Collections;

@Component
@RequiredArgsConstructor
@Slf4j
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    private final JwtUtil jwtUtil;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (accessor != null && StompCommand.CONNECT.equals(accessor.getCommand())) {
            String authToken = accessor.getFirstNativeHeader("Authorization");
            log.info("[WebSocketAuth] Received CONNECT command. Auth header: {}", authToken != null ? "Present" : "Missing");

            if (authToken != null && authToken.startsWith("Bearer ")) {
                String token = authToken.substring(7);
                try {
                    String email = jwtUtil.extractEmail(token);
                    String role = jwtUtil.extractClaim(token, claims -> claims.get("role", String.class));
                    if (email != null && role != null) {
                        Authentication auth = new UsernamePasswordAuthenticationToken(
                            email, null, Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + role))
                        );
                        accessor.setUser(auth);
                        log.info("[WebSocketAuth] Successfully authenticated user: {} with role: {}", email, role);
                    }
                } catch (Exception e) {
                    log.error("[WebSocketAuth] Token validation failed: {}", e.getMessage());
                }
            }
        }
        return message;
    }
}
