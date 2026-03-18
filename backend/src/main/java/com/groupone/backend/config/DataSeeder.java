package com.groupone.backend.config;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserProfile;
import com.groupone.backend.features.identity.UserRepository;
import com.groupone.backend.features.identity.UserProfileRepository;
import com.groupone.backend.shared.enums.UserRole;
import com.groupone.backend.shared.enums.UserStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

        private final UserRepository userRepository;
        private final PasswordEncoder passwordEncoder;
        private final UserProfileRepository profileRepository;

        @Override
        public void run(String... args) throws Exception {
                // Seed Admin
                if (userRepository.findByEmail("admin@englishhub.com").isEmpty()) {
                        User admin = User.builder()
                                        .email("admin@englishhub.com")
                                        .passwordHash(passwordEncoder.encode("admin123"))
                                        .role(UserRole.ADMIN)
                                        .status(UserStatus.ACTIVE)
                                        .isEmailConfirmed(true)
                                        .build();
                        userRepository.save(admin);

                        UserProfile profile = UserProfile.builder()
                                        .user(admin)
                                        .fullName("System Administrator")
                                        .build();
                        profileRepository.save(profile);
                }

                // Seed Teacher
                if (userRepository.findByEmail("teacher@englishhub.com").isEmpty()) {
                        User teacher = User.builder()
                                        .email("teacher@englishhub.com")
                                        .passwordHash(passwordEncoder.encode("Teacher@123"))
                                        .role(UserRole.TEACHER)
                                        .status(UserStatus.ACTIVE)
                                        .isEmailConfirmed(true)
                                        .build();

                        UserProfile teacherProfile = UserProfile.builder()
                                        .user(teacher)
                                        .fullName("Teacher 1")
                                        .build();
                        teacher.setProfile(teacherProfile);
                        userRepository.save(teacher);

                        System.out.println("Sample teacher created: teacher@englishhub.com / Teacher@123");
                }

                // Seed Student
                if (userRepository.findByEmail("student@englishhub.com").isEmpty()) {
                        User student = User.builder()
                                        .email("student@englishhub.com")
                                        .passwordHash(passwordEncoder.encode("Student@123"))
                                        .role(UserRole.CUSTOMER)
                                        .status(UserStatus.ACTIVE)
                                        .isEmailConfirmed(true)
                                        .build();

                        UserProfile studentProfile = UserProfile.builder()
                                        .user(student)
                                        .fullName("Nguyen Van Hoc")
                                        .build();
                        student.setProfile(studentProfile);
                        userRepository.save(student);

                        System.out.println("Sample student created: student@englishhub.com / Student@123");
                }
        }
}
