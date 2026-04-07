package com.groupone.backend.features.tutoring;

import com.groupone.backend.features.icoin.ICoinService;
import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class TutoringSessionService {

    private final TutoringSessionRepository sessionRepository;
    private final ICoinService iCoinService;
    private final UserRepository userRepository;

    @Transactional
    public TutoringSession requestSession(User student, User teacher, int coinAmount) {
        log.info("Requesting tutoring session: Student {} -> Teacher {} for {} coins", student.getId(), teacher.getId(), coinAmount);
        
        TutoringSession session = TutoringSession.builder()
                .student(student)
                .teacher(teacher)
                .coinAmount(coinAmount)
                .status(SessionStatus.PENDING)
                .build();
        
        return sessionRepository.save(session);
    }

    @Transactional
    public void startSession(Long sessionId) {
        TutoringSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Session not found"));

        if (session.getStatus() != SessionStatus.PENDING) {
            throw new IllegalStateException("Session must be in PENDING status to start");
        }

        log.info("Starting session {}. Holding {} coins for student {}", sessionId, session.getCoinAmount(), session.getStudent().getId());
        
        // Mechanism 'Hold': Tạm giữ xu khi session bắt đầu
        iCoinService.holdCoins(session.getStudent(), session.getCoinAmount(), "Holding coins for Session #" + sessionId);

        session.setStatus(SessionStatus.ONGOING);
        session.setStartTime(LocalDateTime.now());
        sessionRepository.save(session);
    }

    @Transactional
    public void completeSession(Long sessionId) {
        TutoringSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Session not found"));

        if (session.getStatus() != SessionStatus.ONGOING) {
            throw new IllegalStateException("Session must be in ONGOING status to complete");
        }

        log.info("Completing session {}. Committing {} coins for student {}", sessionId, session.getCoinAmount(), session.getStudent().getId());

        // Mechanism 'Commit': Trừ hẳn xu khi session COMPLETED
        iCoinService.commitHeldCoins(session.getStudent(), session.getCoinAmount(), "Final payment for Session #" + sessionId);

        session.setStatus(SessionStatus.COMPLETED);
        session.setEndTime(LocalDateTime.now());
        sessionRepository.save(session);
    }

    @Transactional
    public void cancelSession(Long sessionId, String reason) {
        TutoringSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Session not found"));

        if (session.getStatus() == SessionStatus.COMPLETED || session.getStatus() == SessionStatus.CANCELLED) {
            throw new IllegalStateException("Cannot cancel a completed or already cancelled session");
        }

        log.info("Cancelling session {}. Status was: {}. Reason: {}", sessionId, session.getStatus(), reason);

        // Mechanism 'Refund': Hoàn xu nếu session đã 'Hold' mà bị CANCEL
        if (session.getStatus() == SessionStatus.ONGOING) {
            iCoinService.refundHeldCoins(session.getStudent(), session.getCoinAmount(), "Refund for cancelled Session #" + sessionId);
        }

        session.setStatus(SessionStatus.CANCELLED);
        session.setEndTime(LocalDateTime.now());
        sessionRepository.save(session);
    }
}
