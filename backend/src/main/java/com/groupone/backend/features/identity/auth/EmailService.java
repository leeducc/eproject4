package com.groupone.backend.features.identity.auth;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    public void sendOtpEmail(String toEmail, String otp) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject("IELTS App - Your Verification Code");
            
            String htmlContent = "<h2>Registration Verification Code</h2>"
                               + "<p>Welcome to the IELTS App!</p>"
                               + "<p>Your 6-digit verification code is: <strong>" + otp + "</strong></p>"
                               + "<p>This code will expire in 5 minutes.</p>";
                               
            helper.setText(htmlContent, true); 
            
            mailSender.send(message);
        } catch (MessagingException e) {
            throw new RuntimeException("Failed to send OTP email: " + e.getMessage());
        }
    }

    public void sendTeacherAccountEmail(String toEmail, String fullName, String password) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject("IELTS App - Teacher Account Created");
            
            String htmlContent = "<h2>Welcome to the IELTS App Teaching Team!</h2>"
                               + "<p>Hello " + (fullName != null ? fullName : "Teacher") + ",</p>"
                               + "<p>An administrator has created a teacher account for you.</p>"
                               + "<p><strong>Login Email:</strong> " + toEmail + "</p>"
                               + "<p><strong>Password:</strong> " + password + "</p>"
                               + "<p>Please log in and change your password as soon as possible.</p>";
                               
            helper.setText(htmlContent, true); 
            
            mailSender.send(message);
        } catch (MessagingException e) {
            throw new RuntimeException("Failed to send teacher account email: " + e.getMessage());
        }
    }

    public void sendFeedbackResponseEmail(String toEmail, String title, String adminReply) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject("IELTS App - Response to your feedback: " + title);
            
            String htmlContent = "<h2>Feedback Response</h2>"
                               + "<p>Hello,</p>"
                               + "<p>An administrator has responded to your feedback regarding: <strong>" + title + "</strong></p>"
                               + "<p><strong>Reply:</strong><br/>" + adminReply + "</p>"
                               + "<p>Thank you for helping us improve!</p>";
                               
            helper.setText(htmlContent, true); 
            
            mailSender.send(message);
        } catch (MessagingException e) {
            System.err.println("Failed to send feedback response email: " + e.getMessage());
        }
    }
}
