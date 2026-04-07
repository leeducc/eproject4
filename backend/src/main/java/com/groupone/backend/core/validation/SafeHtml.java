package com.groupone.backend.core.validation;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import java.lang.annotation.*;

@Documented
@Constraint(validatedBy = SafeHtmlValidator.class)
@Target({ElementType.FIELD, ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)
public @interface SafeHtml {
    String message() default "Potential XSS detected in input";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}
