package com.groupone.backend.features.identity;

import com.groupone.backend.features.identity.dto.UserResponse;
import com.groupone.backend.features.identity.dto.AddTeacherRequest;
import com.groupone.backend.features.identity.auth.EmailService;
import com.groupone.backend.shared.enums.UserRole;
import com.groupone.backend.shared.enums.UserStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin/users")
@RequiredArgsConstructor
public class AdminUserController {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;

    @GetMapping
    public ResponseEntity<List<UserResponse>> getUsers(
            @RequestParam(required = false) UserRole role,
            @RequestParam(required = false) String search) {
        
        List<User> users = userRepository.findByRoleAndSearch(role, search);
        
        List<UserResponse> responses = users.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
                
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUser(@PathVariable Long id) {
        return userRepository.findById(id)
                .map(user -> ResponseEntity.ok(this.mapToResponse(user)))
                .orElse(ResponseEntity.notFound().build());
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<UserResponse> updateUserStatus(
            @PathVariable Long id,
            @RequestParam UserStatus status) {
        return userRepository.findById(id)
                .map(user -> {
                    user.setStatus(status);
                    user = userRepository.save(user);
                    return ResponseEntity.ok(this.mapToResponse(user));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PatchMapping("/{id}/pro")
    public ResponseEntity<UserResponse> updateUserProStatus(
            @PathVariable Long id,
            @RequestParam Boolean isPro) {
        return userRepository.findById(id)
                .map(user -> {
                    user.setIsPro(isPro);
                    user = userRepository.save(user);
                    return ResponseEntity.ok(this.mapToResponse(user));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PatchMapping("/{id}/icoins")
    public ResponseEntity<UserResponse> updateUserICoinBalance(
            @PathVariable Long id,
            @RequestParam Integer balance) {
        return userRepository.findById(id)
                .map(user -> {
                    user.setICoinBalance(balance);
                    user = userRepository.save(user);
                    return ResponseEntity.ok(this.mapToResponse(user));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        if (userRepository.existsById(id)) {
            userRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping("/teachers")
    public ResponseEntity<UserResponse> createTeacher(@RequestBody AddTeacherRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            return ResponseEntity.badRequest().build();
        }

        User user = User.builder()
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .role(UserRole.TEACHER)
                .status(UserStatus.ACTIVE)
                .isEmailConfirmed(true)
                .build();

        user = userRepository.save(user);

        UserProfile profile = UserProfile.builder()
                .user(user)
                .fullName(request.getFullName())
                .build();
        userProfileRepository.save(profile);

        emailService.sendTeacherAccountEmail(user.getEmail(), profile.getFullName(), request.getPassword());

        return ResponseEntity.ok(this.mapToResponse(user));
    }

    private UserResponse mapToResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .role(user.getRole())
                .status(user.getStatus())
                .fullName(user.getProfile() != null ? user.getProfile().getFullName() : null)
                .address(user.getProfile() != null ? user.getProfile().getAddress() : null)
                .birthday(user.getProfile() != null ? user.getProfile().getBirthday() : null)
                .phoneNumber(user.getProfile() != null ? user.getProfile().getPhoneNumber() : null)
                .createdAt(user.getCreatedAt())
                .isPro(user.getIsPro())
                .iCoinBalance(user.getICoinBalance())
                .isEmailConfirmed(user.isEmailConfirmed())
                .build();
    }
}
