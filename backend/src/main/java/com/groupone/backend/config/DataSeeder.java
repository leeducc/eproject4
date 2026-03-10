package com.groupone.backend.config;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserProfile;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.shared.enums.UserRole;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        if (!userRepository.existsByEmail("user1@gmail.com")) {
            User user = User.builder()
                    .email("user1@gmail.com")
                    .passwordHash(passwordEncoder.encode("User@123"))
                    .role(UserRole.CUSTOMER)
                    .isEmailConfirmed(true)
                    .build();

            UserProfile profile = UserProfile.builder()
                    .user(user)
                    .fullName("Sample User")
                    .build();
            user.setProfile(profile);
            userRepository.save(user);

            System.out.println("Sample user created: user1@gmail.com / User@123");
        }

        if (!userRepository.existsByEmail("admin@gmail.com")) {
            User admin = User.builder()
                    .email("admin@gmail.com")
                    .passwordHash(passwordEncoder.encode("Admin@123"))
                    .role(UserRole.ADMIN)
                    .isEmailConfirmed(true)
                    .build();

            UserProfile adminProfile = UserProfile.builder()
                    .user(admin)
                    .fullName("Admin")
                    .build();
            admin.setProfile(adminProfile);
            userRepository.save(admin);

            System.out.println("Sample admin created: admin@gmail.com / Admin@123");
        }

        if (!userRepository.existsByEmail("teacher1@gmail.com")) {
            User teacher = User.builder()
                    .email("teacher1@gmail.com")
                    .passwordHash(passwordEncoder.encode("Teacher@123"))
                    .role(UserRole.TEACHER)
                    .isEmailConfirmed(true)
                    .build();

            UserProfile teacherProfile = UserProfile.builder()
                    .user(teacher)
                    .fullName("Teacher 1")
                    .build();
            teacher.setProfile(teacherProfile);
            userRepository.save(teacher);

            System.out.println("Sample teacher created: teacher1@gmail.com / Teacher@123");
        }
    }
}
