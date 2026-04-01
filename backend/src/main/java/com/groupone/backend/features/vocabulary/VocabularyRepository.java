package com.groupone.backend.features.vocabulary;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VocabularyRepository extends JpaRepository<VocabularyEntity, Long> {
    
    Optional<VocabularyEntity> findByWord(String word);

    Optional<VocabularyEntity> findFirstByWordIgnoreCase(String word);
    
    Optional<VocabularyEntity> findByWordAndTypeAndPos(String word, String type, String pos);
    
    Page<VocabularyEntity> findAllByTypeAndLevelGroup(String type, String levelGroup, Pageable pageable);
    
    Page<VocabularyEntity> findAllByType(String type, Pageable pageable);

    @org.springframework.data.jpa.repository.Query(value = 
        "SELECT * FROM vocabulary " +
        "WHERE (:type IS NULL OR type = :type) " +
        "AND (:levelGroup IS NULL OR level_group = :levelGroup) " +
        "AND (:lastSeenId IS NULL OR id > :lastSeenId) " +
        "AND (:search IS NULL OR MATCH(word, definition) AGAINST(:search IN NATURAL LANGUAGE MODE)) " +
        "ORDER BY level_group ASC, word ASC LIMIT :limit", 
        nativeQuery = true)
    List<VocabularyEntity> findPaginated(
            @org.springframework.data.repository.query.Param("type") String type, 
            @org.springframework.data.repository.query.Param("levelGroup") String levelGroup, 
            @org.springframework.data.repository.query.Param("search") String search,
            @org.springframework.data.repository.query.Param("lastSeenId") Long lastSeenId, 
            @org.springframework.data.repository.query.Param("limit") int limit);
}
