package com.groupone.backend.features.identity;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.PersistenceException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProfileService {

    private final UserProfileRepository profileRepository;
    private final UserRepository userRepository;

    @PersistenceContext
    private EntityManager entityManager;

    
    @Transactional
    public UserProfile getOrCreateProfile(User user) {
        log.info("[ProfileService] getOrCreateProfile called for user: {}, ID: {}", user.getEmail(), user.getId());

        
        return profileRepository.findById(user.getId())
                .orElseGet(() -> createProfile(user.getId(), user.getEmail()));
    }

    
    private UserProfile createProfile(Long userId, String email) {
        log.info("[ProfileService] No existing profile found for userId: {}. Creating new one.", userId);

        
        
        User managedUser = userRepository.findById(userId).orElseThrow(() -> {
            log.error("[ProfileService] Cannot create profile — User ID {} not found in DB!", userId);
            return new IllegalStateException("User not found for profile creation, ID: " + userId);
        });
        log.debug("[ProfileService] Managed user loaded: {}", managedUser.getEmail());

        String defaultName = (email != null && email.contains("@"))
                ? email.split("@")[0]
                : "User " + userId;

        UserProfile newProfile = UserProfile.builder()
                .id(userId)
                .user(managedUser)
                .fullName(defaultName)
                .build();

        try {
            
            
            
            
            entityManager.persist(newProfile);
            entityManager.flush();
            log.info("[ProfileService] Profile created successfully for userId: {}", userId);
            return newProfile;
        } catch (PersistenceException e) {
            
            
            log.warn("[ProfileService] Concurrent profile creation for userId: {}. Fetching existing. Error: {}",
                    userId, e.getMessage());
            entityManager.clear();
            return profileRepository.findById(userId)
                    .orElseThrow(() -> {
                        log.error("[ProfileService] Re-fetch after concurrent creation still empty for userId: {}!", userId);
                        return new IllegalStateException(
                                "Failed to retrieve or create profile for user ID: " + userId);
                    });
        }
    }
}
