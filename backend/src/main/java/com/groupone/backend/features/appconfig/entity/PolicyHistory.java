package com.groupone.backend.features.appconfig.entity;

import com.groupone.backend.features.identity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "policy_history")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PolicyHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "policy_id", nullable = false)
    private Policy policy;

    @Column(nullable = false)
    private String type; 

    private String titleEn;
    private String titleVi;
    private String titleZh;

    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String contentEn;

    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String contentVi;

    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String contentZh;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "admin_id", nullable = false)
    private User admin;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime changedAt;
}
