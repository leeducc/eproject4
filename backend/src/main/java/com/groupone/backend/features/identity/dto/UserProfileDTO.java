package com.groupone.backend.features.identity.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileDTO {
    private Long userId;
    private String email;
    private String role;
    private String fullName;
    private String avatarUrl;
    private String bio;
    private String address;
    private LocalDate birthday;
    private String phoneNumber;
}
