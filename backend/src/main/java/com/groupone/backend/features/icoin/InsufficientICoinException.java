package com.groupone.backend.features.icoin;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.PAYMENT_REQUIRED)
public class InsufficientICoinException extends RuntimeException {
    public InsufficientICoinException(String message) {
        super(message);
    }
}
