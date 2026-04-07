package com.groupone.backend.features.identity.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AddTeacherRequest {
    private String email;
    private String fullName;
    private String password;
}
