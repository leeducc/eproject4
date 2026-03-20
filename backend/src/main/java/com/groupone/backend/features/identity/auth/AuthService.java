package com.groupone.backend.features.identity.auth;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserProfile;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.features.identity.UserProfileRepository;
import com.groupone.backend.features.identity.dto.AuthResponse;
import com.groupone.backend.features.identity.dto.LoginRequest;
import com.groupone.backend.features.identity.dto.RegisterRequest;
import com.groupone.backend.features.identity.dto.ResetPasswordRequest;
import com.groupone.backend.features.identity.dto.GoogleLoginRequest;
import com.groupone.backend.shared.enums.UserRole;
import com.groupone.backend.shared.enums.UserStatus;
import com.groupone.backend.shared.exception.AccountSuspendedException;
import com.groupone.backend.shared.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;

import java.util.Collections;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final EmailService emailService;
    private final OtpCacheService otpCacheService;
    private final CaptchaVerificationService captchaVerificationService;

    @Value("${google.client.id}")
    private String googleClientId;

    public void sendOtp(String email, String captchaToken) {
        if (!captchaVerificationService.verifyToken(captchaToken)) {
            throw new IllegalArgumentException("reCAPTCHA verification failed. Please try again.");
        }

        if (userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email is already registered");
        }
        String otp = otpCacheService.generateAndStoreOtp(email);
        emailService.sendOtpEmail(email, otp);
    }

    public void register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email is already registered");
        }

        // Validate OTP against our cache
        if (!otpCacheService.validateOtp(request.getEmail(), request.getCode())) {
            throw new IllegalArgumentException("Invalid or expired verification code");
        }

        User user = User.builder()
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .role(UserRole.CUSTOMER) // Default role for app signups
                .isEmailConfirmed(true) // Confirmed because they entered the OTP correctly
                .build();

        user = userRepository.save(user);

        // Create empty profile
        UserProfile profile = UserProfile.builder()
                .user(user)
                .build();
        userProfileRepository.save(profile);
    }

    public AuthResponse login(LoginRequest request) {
        long t0 = System.currentTimeMillis();
        System.out.println("[AuthService] login() started for: " + request.getEmail());

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("Invalid email or password"));
        System.out.println("[AuthService] DB lookup took " + (System.currentTimeMillis() - t0) + "ms");

        long t1 = System.currentTimeMillis();
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            System.out.println("[AuthService] BCrypt check took " + (System.currentTimeMillis() - t1) + "ms (password mismatch)");
            throw new IllegalArgumentException("Invalid email or password");
        }
        System.out.println("[AuthService] BCrypt check took " + (System.currentTimeMillis() - t1) + "ms (OK)");

        if (user.getStatus() == UserStatus.SUSPENDED) {
            System.out.println("LOGIN ERROR: Account suspended for email: " + user.getEmail());
            throw new AccountSuspendedException("Your account has been suspended. Please contact support.");
        }

        long t2 = System.currentTimeMillis();
        String token = jwtUtil.generateToken(user);
        System.out.println("[AuthService] JWT generation took " + (System.currentTimeMillis() - t2) + "ms");

        String fullName = user.getProfile() != null ? user.getProfile().getFullName() : null;

        System.out.println("[AuthService] login() total time: " + (System.currentTimeMillis() - t0) + "ms");
        return AuthResponse.builder()
                .id(user.getId())
                .token(token)
                .email(user.getEmail())
                .role(user.getRole())
                .fullName(fullName)
                .isPro(user.getIsPro() != null ? user.getIsPro() : false)
                .build();
    }

    public AuthResponse loginWithGoogle(GoogleLoginRequest request) {
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(),
                    new GsonFactory())
                    .setAudience(Collections.singletonList(googleClientId))
                    .build();

            GoogleIdToken idToken = verifier.verify(request.getIdToken());
            if (idToken != null) {
                Payload payload = idToken.getPayload();
                String email = payload.getEmail();

                User user = userRepository.findByEmail(email).orElseGet(() -> {
                    // Create new user if they don't exist
                    User newUser = User.builder()
                            .email(email)
                            // Generate random complex password since they login with google
                            .passwordHash(passwordEncoder.encode(UUID.randomUUID().toString()))
                            .role(UserRole.CUSTOMER)
                            .isEmailConfirmed(payload.getEmailVerified() != null ? payload.getEmailVerified() : true)
                            .build();
                    newUser = userRepository.save(newUser);

                    // Create empty profile
                    UserProfile profile = UserProfile.builder()
                            .user(newUser)
                            .fullName((String) payload.get("name"))
                            .build();
                    userProfileRepository.save(profile);

                    return newUser;
                });

                if (user.getStatus() == UserStatus.SUSPENDED) {
                    System.out.println("GOOGLE LOGIN ERROR: Account suspended for email: " + user.getEmail());
                    throw new AccountSuspendedException("Your account has been suspended. Please contact support.");
                }

                String token = jwtUtil.generateToken(user);
                String fullName = user.getProfile() != null ? user.getProfile().getFullName() : null;

                return AuthResponse.builder()
                        .id(user.getId())
                        .token(token)
                        .email(user.getEmail())
                        .role(user.getRole())
                        .fullName(fullName)
                        .isPro(user.getIsPro() != null ? user.getIsPro() : false)
                        .build();

            } else {
                throw new IllegalArgumentException("Invalid Google ID token.");
            }
        } catch (Exception e) {
            throw new IllegalArgumentException("Google authentication failed: " + e.getMessage());
        }
    }

    public void sendForgotPasswordOtp(String email, String captchaToken) {
        if (!captchaVerificationService.verifyToken(captchaToken)) {
            throw new IllegalArgumentException("reCAPTCHA verification failed. Please try again.");
        }

        if (!userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email is not registered");
        }
        String otp = otpCacheService.generateAndStoreOtp(email);
        emailService.sendOtpEmail(email, otp);
    }

    public void resetPassword(ResetPasswordRequest request) {
        if (!otpCacheService.validateOtp(request.getEmail(), request.getCode())) {
            throw new IllegalArgumentException("Invalid or expired verification code");
        }

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }
}
