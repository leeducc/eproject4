package com.groupone.backend.features.identity;

import com.groupone.backend.features.identity.dto.UserProfileDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import org.springframework.transaction.annotation.Transactional;

@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
@Slf4j
public class ProfileController {

    private final ProfileService profileService;
    private final UserProfileRepository profileRepository;
    private final UserRepository userRepository;
    private final org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;

    @GetMapping
    public ResponseEntity<UserProfileDTO> getProfile(@AuthenticationPrincipal User user) {
        log.info("[ProfileController] GET /api/profile for user: {}", (user != null ? user.getEmail() : "ANONYMOUS"));
        try {
            if (user == null) {
                log.warn("[ProfileController] Unauthorized access attempt to get profile");
                return ResponseEntity.status(401).build();
            }
            log.info("[ProfileController] Getting profile for user: {}, ID: {}, Role: {}", 
                user.getEmail(), user.getId(), user.getRole());
            
            
            UserProfile profile = profileService.getOrCreateProfile(user);

            
            if (profile.getUser() == null) {
                log.warn("[ProfileController] User relation is null for profile ID: {}, linking from security context", profile.getId());
                profile.setUser(user);
            }

            log.info("[ProfileController] Returning profile for id: {}", profile.getId());
            return ResponseEntity.ok(mapToDTO(profile));
        } catch (Exception e) {
            log.error("[ProfileController] FATAL error in getProfile for user: {}. Error type: {}, Message: {}", 
                (user != null ? user.getEmail() : "UNKNOWN"), e.getClass().getName(), e.getMessage(), e);
            return ResponseEntity.status(500).build();
        }
    }

    @PutMapping
    public ResponseEntity<UserProfileDTO> updateProfile(
            @AuthenticationPrincipal User user,
            @RequestBody UserProfileDTO dto) {
        if (user == null) return ResponseEntity.status(401).build();
        log.info("[ProfileController] PUT /api/profile for user: {}", user.getEmail());
        
        UserProfile profile = profileRepository.findById(user.getId())
                .orElseGet(() -> {
                    log.info("[ProfileController] Creating new UserProfile record for user id: {}", user.getId());
                    return UserProfile.builder()
                        .id(user.getId())
                        .user(user)
                        .build();
                });

        profile.setFullName(dto.getFullName());
        profile.setAvatarUrl(dto.getAvatarUrl());
        profile.setBio(dto.getBio());
        profile.setAddress(dto.getAddress());
        profile.setBirthday(dto.getBirthday());
        profile.setPhoneNumber(dto.getPhoneNumber());
        
        UserProfile savedProfile = profileRepository.save(profile);
        log.info("[ProfileController] SAVED profile for user: {}", user.getEmail());
        return ResponseEntity.ok(mapToDTO(savedProfile));
    }

    @PostMapping("/change-password")
    @Transactional
    public ResponseEntity<?> changePassword(
            @AuthenticationPrincipal User user,
            @RequestBody com.groupone.backend.features.identity.dto.ChangePasswordRequest request) {
        if (user == null) return ResponseEntity.status(401).build();
        log.info("[ProfileController] POST /api/profile/change-password for user: {}", user.getEmail());

        if (passwordEncoder.matches(request.getCurrentPassword(), user.getPasswordHash())) {
            user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
            userRepository.save(user);
            log.info("[ProfileController] Password UPDATED for user: {}", user.getEmail());
            return ResponseEntity.ok().build();
        } else {
            log.warn("[ProfileController] Password update FAILED: Current password mismatch for user: {}", user.getEmail());
            return ResponseEntity.badRequest().body("Current password is incorrect");
        }
    }

    @DeleteMapping
    public ResponseEntity<Void> deleteProfile(@AuthenticationPrincipal User user) {
        if (user == null) return ResponseEntity.status(401).build();
        log.info("[ProfileController] Deleting account for user: {}", user.getEmail());
        userRepository.deleteById(user.getId());
        return ResponseEntity.noContent().build();
    }

    private UserProfileDTO mapToDTO(UserProfile profile) {
        User user = profile.getUser();
        if (user == null) {
            log.error("[ProfileController] CRITICAL: User relation is null in mapToDTO for profile id {}", profile.getId());
            
            throw new IllegalStateException("User relation cannot be null for profile ID: " + profile.getId());
        }
        
        log.debug("[ProfileController] Mapping profile to DTO for user: {}", user.getEmail());
        
        return UserProfileDTO.builder()
                .userId(user.getId())
                .email(user.getEmail())
                .role(user.getRole() != null ? user.getRole().name() : "USER")
                .fullName(profile.getFullName())
                .avatarUrl(profile.getAvatarUrl())
                .bio(profile.getBio())
                .address(profile.getAddress())
                .birthday(profile.getBirthday())
                .phoneNumber(profile.getPhoneNumber())
                .build();
    }
}
