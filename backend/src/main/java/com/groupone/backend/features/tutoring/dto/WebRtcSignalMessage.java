package com.groupone.backend.features.tutoring.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WebRtcSignalMessage {
    private String type; // offer, answer, ice-candidate
    private Object data; // SDP content or ICE candidate object
    private String fromUser;
    private String toUser;
}
