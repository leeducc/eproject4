package com.groupone.backend.features.identity;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserProfileRepository extends JpaRepository<UserProfile, Long> {
    @EntityGraph(attributePaths = {"user"})
    Optional<UserProfile> findById(Long id);
}
