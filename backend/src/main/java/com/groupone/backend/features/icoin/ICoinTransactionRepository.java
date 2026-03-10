package com.groupone.backend.features.icoin;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ICoinTransactionRepository extends JpaRepository<ICoinTransaction, Long> {
    List<ICoinTransaction> findByUserIdOrderByCreatedAtDesc(Long userId);

    List<ICoinTransaction> findAllByOrderByCreatedAtDesc();
}
