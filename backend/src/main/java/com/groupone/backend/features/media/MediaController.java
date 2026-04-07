package com.groupone.backend.features.media;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import com.groupone.backend.features.identity.User;

@RestController
@RequestMapping("/api/media")
public class MediaController {

    private final MediaService mediaService;

    public MediaController(MediaService mediaService) {
        this.mediaService = mediaService;
    }

    @PostMapping("/upload")
    public ResponseEntity<?> uploadMedia(
            @AuthenticationPrincipal User user,
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "context", required = false) String context) {
        try {
            if (user == null) {
                return ResponseEntity.status(401).body("Authentication required for upload");
            }
            
            Long uploaderId = user.getId();

            MediaFile uploadedFile = mediaService.uploadFile(file, uploaderId, context);

            
            return ResponseEntity.ok(uploadedFile);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Failed to upload file: " + e.getMessage());
        }
    }
}
