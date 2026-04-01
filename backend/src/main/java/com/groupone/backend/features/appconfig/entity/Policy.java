package com.groupone.backend.features.appconfig.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "policies")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Policy {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String type; // "TERMS", "PRIVACY"

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

    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
