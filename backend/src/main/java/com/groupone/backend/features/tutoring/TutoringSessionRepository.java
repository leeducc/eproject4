package com.groupone.backend.features.tutoring;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TutoringSessionRepository extends JpaRepository<TutoringSession, Long> {
    List<TutoringSession> findAllByStudentIdOrderByCreatedAtDesc(Long studentId);
    List<TutoringSession> findAllByTeacherIdOrderByCreatedAtDesc(Long teacherId);
}
