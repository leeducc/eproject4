package com.groupone.backend.features.writing;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "writing_topic")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WritingTopic {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(columnDefinition = "TEXT")
    private String hint;

    private String imageUrl;

    private String audioUrl;

    @Column(name = "is_pro_only", nullable = false)
    @Builder.Default
    private Boolean isProOnly = false;
}
