package com.groupone.backend.features.writing.dto;

import com.groupone.backend.features.writing.WritingTopic;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TopicResponse {
    private Long id;
    private String title;
    private String description;
    private String hint;
    private String imageUrl;
    private String audioUrl;
    private Boolean isProOnly;

    public static TopicResponse fromEntity(WritingTopic topic) {
        return TopicResponse.builder()
                .id(topic.getId())
                .title(topic.getTitle())
                .description(topic.getDescription())
                .hint(topic.getHint())
                .imageUrl(topic.getImageUrl())
                .audioUrl(topic.getAudioUrl())
                .isProOnly(topic.getIsProOnly() != null ? topic.getIsProOnly() : false)
                .build();
    }
}
