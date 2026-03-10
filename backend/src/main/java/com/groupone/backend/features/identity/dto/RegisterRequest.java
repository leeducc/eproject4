package com.groupone.backend.features.identity.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RegisterRequest {
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Password is required")
    private String password;

    @NotBlank(message = "Verification code is required")
    private String code; // Currently mocked as 123456 in frontend

    // Add recaptcha token if needed in the future, for now backend just verifies
    // the OTP code
}
