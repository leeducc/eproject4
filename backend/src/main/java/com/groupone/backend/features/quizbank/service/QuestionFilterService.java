package com.groupone.backend.features.quizbank.service;

import com.groupone.backend.features.quizbank.dto.FilterGroup;
import com.groupone.backend.features.quizbank.dto.FilterRequest;
import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.entity.Tag;
import com.groupone.backend.features.quizbank.repository.QuestionRepository;
import jakarta.persistence.criteria.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class QuestionFilterService {

    @Autowired
    private QuestionRepository questionRepository;

    public List<Question> filterQuestions(FilterRequest request) {
        Specification<Question> spec = (root, query, cb) -> {
            List<Predicate> groupPredicates = new ArrayList<>();

            for (FilterGroup group : request.getGroups()) {
                Predicate groupPredicate = buildGroupPredicate(root, query, cb, group);
                if (groupPredicate != null) {
                    groupPredicates.add(groupPredicate);
                }
            }

            if (groupPredicates.isEmpty()) return null;

            Predicate finalTagsPredicate = "OR".equalsIgnoreCase(request.getLogic()) 
                ? cb.or(groupPredicates.toArray(new Predicate[0])) 
                : cb.and(groupPredicates.toArray(new Predicate[0]));

            if (request.getSkill() != null && !request.getSkill().isEmpty()) {
                return cb.and(finalTagsPredicate, cb.equal(root.get("skill"), request.getSkill().toUpperCase()));
            }

            return finalTagsPredicate;
        };

        return questionRepository.findAll(spec);
    }

    private Predicate buildGroupPredicate(Root<Question> root, CriteriaQuery<?> query, CriteriaBuilder cb, FilterGroup group) {
        List<Predicate> tagPredicates = new ArrayList<>();
        
        for (String tagStr : group.getTags()) {
            String[] parts = tagStr.split(":");
            String namespace = parts[0].trim();
            String name = parts.length > 1 ? parts[1].trim() : null;

            // Subquery to check for tag existence to avoid cross-product issues with joins
            Subquery<Long> subquery = query.subquery(Long.class);
            Root<Question> subRoot = subquery.from(Question.class);
            Join<Question, Tag> join = subRoot.join("tags");
            
            subquery.select(subRoot.get("id"));
            
            Predicate tagMatch;
            if (name != null) {
                tagMatch = cb.and(
                    cb.equal(join.get("namespace"), namespace),
                    cb.equal(join.get("name"), name)
                );
            } else {
                tagMatch = cb.equal(join.get("name"), namespace); // fallback if no colon
            }
            
            subquery.where(cb.and(cb.equal(subRoot.get("id"), root.get("id")), tagMatch));
            
            tagPredicates.add(cb.exists(subquery));
        }

        if (tagPredicates.isEmpty()) return null;

        return "OR".equalsIgnoreCase(group.getLogic())
            ? cb.or(tagPredicates.toArray(new Predicate[0]))
            : cb.and(tagPredicates.toArray(new Predicate[0]));
    }
}
