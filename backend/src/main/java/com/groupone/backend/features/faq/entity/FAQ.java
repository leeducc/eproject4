package com.groupone.backend.features.faq.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "faqs")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FAQ {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String questionEn;

    @Column(nullable = false)
    private String questionVi;

    @Column(nullable = false)
    private String questionZh;

    @Lob
    @Column(columnDefinition = "LONGTEXT", nullable = false)
    private String answerEn;

    @Lob
    @Column(columnDefinition = "LONGTEXT", nullable = false)
    private String answerVi;

    @Lob
    @Column(columnDefinition = "LONGTEXT", nullable = false)
    private String answerZh;

    @Column(nullable = false)
    private Integer displayOrder;

    @Column(nullable = false)
    private Boolean isActive;

    @CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
