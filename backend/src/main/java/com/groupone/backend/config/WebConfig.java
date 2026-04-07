package com.groupone.backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.io.File;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${media.upload.dir:d:/project/eproject4/backend/uploads}")
    private String uploadDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        
        
        String pathPrefix = "file:" + (uploadDir.endsWith("/") ? uploadDir : uploadDir + "/");
        
        System.out.println("[WebConfig] Registering resource handler: /media/** -> " + pathPrefix);
        
        registry.addResourceHandler("/media/**")
                .addResourceLocations(pathPrefix);
    }
}
