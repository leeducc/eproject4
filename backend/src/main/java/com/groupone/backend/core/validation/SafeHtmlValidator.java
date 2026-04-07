package com.groupone.backend.core.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.safety.Safelist;

public class SafeHtmlValidator implements ConstraintValidator<SafeHtml, String> {

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (value == null || value.isEmpty()) {
            return true;
        }

        
        
        
        String sanitized = Jsoup.clean(value, Safelist.none());
        
        
        
        
        boolean isValid = value.equals(sanitized);
        
        System.out.println("[SafeHtmlValidator] Validating: " + value + " -> Valid: " + isValid);
        return isValid;
    }
}
