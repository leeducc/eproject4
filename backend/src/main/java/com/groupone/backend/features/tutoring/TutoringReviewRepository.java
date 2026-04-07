package com.groupone.backend.features.tutoring;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TutoringReviewRepository extends JpaRepository<TutoringReview, Long> {
    List<TutoringReview> findAllByTeacherIdOrderByCreatedAtDesc(Long teacherId);
    List<TutoringReview> findAllByStudentIdOrderByCreatedAtDesc(Long studentId);

    @Query("SELECT AVG(r.rating) FROM TutoringReview r WHERE r.teacher.id = :teacherId")
    Double getAverageRatingByTeacherId(@Param("teacherId") Long teacherId);
}
