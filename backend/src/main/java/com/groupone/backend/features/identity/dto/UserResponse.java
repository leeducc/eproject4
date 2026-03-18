package com.groupone.backend.features.identity.dto;

import com.groupone.backend.shared.enums.UserRole;
import lombok.AllArgsConstructor;
import com.groupone.backend.shared.enums.UserStatus;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {
    private Long id;
    private String email;
    private UserRole role;
    private UserStatus status;
    private String fullName;
    private String address;
    private java.time.LocalDate birthday;
    private String phoneNumber;
    private LocalDateTime createdAt;
    private Boolean isPro;
    private Integer iCoinBalance;
    private boolean isEmailConfirmed;
}
