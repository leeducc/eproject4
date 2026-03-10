package com.groupone.backend.features.identity.auth;

import org.springframework.stereotype.Service;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.Random;

@Service
public class OtpCacheService {

    // Simulating a temporary cache for OTPs instead of using full Redis immediately
    private final Map<String, String> otpStorage = new ConcurrentHashMap<>();
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    private final Random random = new Random();

    public String generateAndStoreOtp(String email) {
        // Generate a 6-digit OTP
        String otp = String.format("%06d", random.nextInt(999999));

        // Store the OTP against the email (replaces any previous OTP, invalidating it)
        otpStorage.put(email, otp);

        // Schedule deletion after 5 minutes
        scheduler.schedule(() -> otpStorage.remove(email, otp), 5, TimeUnit.MINUTES);

        return otp;
    }

    public boolean validateOtp(String email, String otp) {
        String storedOtp = otpStorage.get(email);
        if (storedOtp != null && storedOtp.equals(otp)) {
            otpStorage.remove(email); // Invalidate OTP after successful validation
            return true;
        }
        return false;
    }
}
