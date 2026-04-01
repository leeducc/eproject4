package com.groupone.backend.features.smarttest.repository;

import com.groupone.backend.features.smarttest.entity.UserTestSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserTestSessionRepository extends JpaRepository<UserTestSession, Long> {
}
