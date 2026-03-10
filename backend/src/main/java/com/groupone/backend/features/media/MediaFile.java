package com.groupone.backend.features.media;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "media_files")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MediaFile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String originalName;
    private String storedName; // The UUID filename on disk
    private String storedPath; // e.g /media/videos/uuid.mp4
    private String mimeType;
    private Long fileSize; // Bytes

    private LocalDateTime uploadedAt;

    private Long uploadedByUserId; // Optional: map to UserProfile id
}
