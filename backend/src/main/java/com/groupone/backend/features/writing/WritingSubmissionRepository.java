package com.groupone.backend.features.writing;

import com.groupone.backend.features.identity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WritingSubmissionRepository extends JpaRepository<WritingSubmission, Long> {
    List<WritingSubmission> findByStudentOrderByCreatedAtDesc(User student);
}
