package com.groupone.backend.features.identity.register;

import com.groupone.backend.features.identity.dto.RegisterRequest;
import com.groupone.backend.features.identity.dto.SendOtpRequest;
import com.groupone.backend.features.identity.auth.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;

@RestController
@RequestMapping("/api/auth/register")
@RequiredArgsConstructor
public class RegisterController {

    private final AuthService authService;

    @GetMapping("/check-email")
    public ResponseEntity<?> checkEmail(@RequestParam String email) {
        boolean available = authService.checkEmailAvailability(email);
        return ResponseEntity.ok().body(Collections.singletonMap("available", available));
    }

    @PostMapping("/send-otp")
    public ResponseEntity<?> sendOtp(@Valid @RequestBody SendOtpRequest request) {
        try {
            authService.sendOtp(request.getEmail(), request.getCaptchaToken());
            return ResponseEntity.ok().body("Verification code sent to email.");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Failed to send email");
        }
    }

    @PostMapping
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {
        try {
            authService.register(request);
            return ResponseEntity.ok().body("Registration successful. You can now login.");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
