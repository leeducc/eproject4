package com.groupone.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TopicDto {
    private Long id;
    private String title;
    private String description;
    private String hint;
    private String imageUrl;
    private String audioUrl;
}
