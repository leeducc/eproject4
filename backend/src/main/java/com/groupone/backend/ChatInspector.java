package com.groupone.backend;

import com.groupone.backend.features.chat.ChatMessage;
import com.groupone.backend.features.chat.ChatMessageRepository;
import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class ChatInspector implements CommandLineRunner {
    private final UserRepository userRepository;
    private final ChatMessageRepository chatMessageRepository;

    public ChatInspector(UserRepository userRepository, ChatMessageRepository chatMessageRepository) {
        this.userRepository = userRepository;
        this.chatMessageRepository = chatMessageRepository;
    }

    @Override
    public void run(String... args) throws Exception {
        System.out.println("--- CHAT INSPECTION ---");
        System.out.println("USERS:");
        userRepository.findAll().forEach(u -> {
            System.out.println("ID: " + u.getId() + ", Email: " + u.getEmail() + ", Role: " + u.getRole());
        });
        
        System.out.println("\nMESSAGES:");
        chatMessageRepository.findAll().forEach(m -> {
            System.out.println("ID: " + m.getId() + ", Sender ID: " + m.getSender().getId() + ", Receiver ID: " + m.getReceiver().getId() + ", Content: " + m.getContent());
        });
        System.out.println("--- END INSPECTION ---");
    }
}
