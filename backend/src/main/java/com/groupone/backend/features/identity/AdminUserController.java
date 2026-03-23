package com.groupone.backend.features.identity;

import com.groupone.backend.features.identity.dto.UserResponse;
import com.groupone.backend.shared.enums.UserRole;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin/users")
@RequiredArgsConstructor
public class AdminUserController {

    private final UserRepository userRepository;

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
