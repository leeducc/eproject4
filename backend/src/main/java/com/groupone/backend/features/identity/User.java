package com.groupone.backend.features.identity;

import com.groupone.backend.shared.enums.UserRole;
import com.groupone.backend.shared.enums.UserStatus;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserRole role;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private UserStatus status = UserStatus.INACTIVE;

    @Builder.Default
    @Column(name = "is_email_confirmed", nullable = false)
    private boolean isEmailConfirmed = false;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "icoin_balance", nullable = false)
    @Builder.Default
    private Integer iCoinBalance = 0;

    @Column(name = "is_pro", nullable = false)
    @Builder.Default
    private Boolean isPro = false;

    @Column(name = "pro_expiry_date")
    private LocalDateTime proExpiryDate;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private UserProfile profile;
}
