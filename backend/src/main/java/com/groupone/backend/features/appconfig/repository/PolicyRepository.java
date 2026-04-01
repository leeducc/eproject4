package com.groupone.backend.features.appconfig.repository;

import com.groupone.backend.features.appconfig.entity.Policy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PolicyRepository extends JpaRepository<Policy, Long> {
    Optional<Policy> findByType(String type);
}
