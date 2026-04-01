package com.groupone.backend.features.smarttest.entity;

import com.groupone.backend.features.identity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_test_sessions")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserTestSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @ToString.Exclude
    private User user;

    @CreationTimestamp
    @Column(name = "start_time", nullable = false, updatable = false)
    private LocalDateTime startTime;

    @Column(name = "end_time")
    private LocalDateTime endTime;

    @Column
    private Double score;

    @Column(name = "test_type", nullable = false)
    @Builder.Default
    private String testType = "smart_test";

    @Column(length = 50)
    private String skill;

    @Column(name = "difficulty_band", length = 50)
    private String difficultyBand;
}
