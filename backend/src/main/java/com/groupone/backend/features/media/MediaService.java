package com.groupone.backend.features.media;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.Objects;
import java.util.UUID;

@Service
public class MediaService {

    
    @Value("${media.upload.dir:d:/project/eproject4/backend/uploads}")
    private String uploadDir;

    private final MediaFileRepository mediaRepository;

    public MediaService(MediaFileRepository mediaRepository) {
        this.mediaRepository = mediaRepository;
    }

    public MediaFile uploadFile(MultipartFile file, Long uploaderId, String context) throws IOException {
        String originalFilename = StringUtils.cleanPath(Objects.requireNonNull(file.getOriginalFilename()));
        String extension = getExtension(originalFilename);

        validateFile(file, extension);

        String storedFilename = UUID.randomUUID().toString() + extension;

        
        String subDir = getSubDir(extension, context);
        Path targetLocation = Paths.get(uploadDir, subDir).toAbsolutePath().normalize();

        Files.createDirectories(targetLocation);
        Path targetFile = targetLocation.resolve(storedFilename);

        
        Files.copy(file.getInputStream(), targetFile, StandardCopyOption.REPLACE_EXISTING);

        
        
        String servedUrl = "/media/" + subDir + "/" + storedFilename;

        MediaFile mediaFile = MediaFile.builder()
                .originalName(originalFilename)
                .storedName(storedFilename)
                .storedPath(servedUrl)
                .mimeType(file.getContentType())
                .fileSize(file.getSize())
                .uploadedAt(LocalDateTime.now())
                .uploadedByUserId(uploaderId)
                .build();

        return mediaRepository.save(mediaFile);
    }

    private void validateFile(MultipartFile file, String extension) {
        long sizeBytes = file.getSize();
        long sizeMb = sizeBytes / (1024 * 1024);

        if (extension.equalsIgnoreCase(".mp4") && sizeMb > 100) {
            throw new IllegalArgumentException("MP4 file size exceeds 100MB limit.");
        } else if (extension.equalsIgnoreCase(".mp3") && sizeMb > 20) {
            throw new IllegalArgumentException("MP3 file size exceeds 20MB limit.");
        } else if ((extension.matches("(?i)\\.(jpg|jpeg|png|gif|webp|pdf)")) && sizeMb <= 10) {
            
            return;
        } else if (!extension.equalsIgnoreCase(".mp4") && !extension.equalsIgnoreCase(".mp3") && sizeMb > 5) {
            throw new IllegalArgumentException("File size exceeds 5MB limit for this type.");
        }
    }

    private String getSubDir(String extension, String context) {
        if (extension.matches("(?i)\\.(mp4|avi|mov|mkv)"))
            return "videos";
        if (extension.matches("(?i)\\.(mp3|wav|ogg)"))
            return "audio";
        if (extension.matches("(?i)\\.(jpg|jpeg|png|gif|webp)")) {
            
            if (StringUtils.hasText(context) && (
                    context.equalsIgnoreCase("questions") || 
                    context.equalsIgnoreCase("answers") ||
                    context.equalsIgnoreCase("avatars"))) {
                return context.toLowerCase();
            }
            return "answers";
        }
        return "documents";
    }

    private String getExtension(String filename) {
        int dotIndex = filename.lastIndexOf('.');
        return (dotIndex == -1) ? "" : filename.substring(dotIndex);
    }
}
