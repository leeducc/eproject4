package com.groupone.backend.shared.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public enum ErrorCode {
    UNCATEGORIZED_EXCEPTION("UNCATEGORIZED_EXCEPTION", "Uncategorized exception", HttpStatus.INTERNAL_SERVER_ERROR),
    INVALID_KEY("INVALID_KEY", "Uncategorized exception", HttpStatus.BAD_REQUEST),
    USER_EXISTED("USER_EXISTED", "User existed", HttpStatus.BAD_REQUEST),
    USER_NOT_EXISTED("USER_NOT_EXISTED", "User not existed", HttpStatus.NOT_FOUND),
    UNAUTHENTICATED("UNAUTHENTICATED", "Unauthenticated", HttpStatus.UNAUTHORIZED),
    UNAUTHORIZED("UNAUTHORIZED", "You do not have permission", HttpStatus.FORBIDDEN),
    RESOURCE_NOT_FOUND("RESOURCE_NOT_FOUND", "Resource not found", HttpStatus.NOT_FOUND),
    COURSE_CODE_EXISTS("course.code.exists", "Course code already exists", HttpStatus.BAD_REQUEST),
    INVALID_REQUEST("INVALID_REQUEST", "Invalid request", HttpStatus.BAD_REQUEST),
    ;

    private final String code;
    private final String message;
    private final HttpStatus httpStatus;

    ErrorCode(String code, String message, HttpStatus httpStatus) {
        this.code = code;
        this.message = message;
        this.httpStatus = httpStatus;
    }
}
