package com.groupone.backend.features.appconfig.entity;

import com.groupone.backend.features.quizbank.entity.Tag;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "app_screen_sections")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AppScreenSection {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String skill; // listening or reading

    @Column(nullable = false)
    private String sectionName;

    @Column(nullable = false)
    private String difficultyBand; // "0-4", "4.5-5.0", etc

    @Column(nullable = false)
    private Integer displayOrder;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "app_section_tags",
        joinColumns = @JoinColumn(name = "section_id"),
        inverseJoinColumns = @JoinColumn(name = "tag_id")
    )
    @Builder.Default
    private java.util.List<Tag> tags = new java.util.ArrayList<>();

    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String guideContent;
}
