package com.groupone.backend.features.feedback.dto;

import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class FeedbackDetailDto {
    private FeedbackDto feedback;
    private List<FeedbackMessageDto> messages;
}
