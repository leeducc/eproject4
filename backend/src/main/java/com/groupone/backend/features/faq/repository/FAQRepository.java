package com.groupone.backend.features.faq.repository;

import com.groupone.backend.features.faq.entity.FAQ;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FAQRepository extends JpaRepository<FAQ, Long> {
    List<FAQ> findAllByIsActiveOrderByDisplayOrderAsc(Boolean isActive);
    List<FAQ> findAllByOrderByDisplayOrderAsc();
}
