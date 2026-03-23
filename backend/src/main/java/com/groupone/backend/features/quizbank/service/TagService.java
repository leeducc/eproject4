package com.groupone.backend.features.quizbank.service;

import com.groupone.backend.features.quizbank.entity.Tag;
import com.groupone.backend.features.quizbank.repository.TagRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class TagService {

    @Autowired
    private TagRepository tagRepository;

    public List<Tag> getAllTags() {
        return tagRepository.findAll();
    }

    public List<Tag> getTagsByNamespace(String namespace) {
        return tagRepository.findAll().stream()
                .filter(t -> t.getNamespace().equalsIgnoreCase(namespace))
                .collect(Collectors.toList());
    }

    public Tag createTag(Tag tag) {
        return tagRepository.save(tag);
    }

    public Tag getOrCreateTag(String name, String namespace) {
        return tagRepository.findByNameAndNamespace(name, namespace)
                .orElseGet(() -> tagRepository.save(Tag.builder()
                        .name(name)
                        .namespace(namespace)
                        .build()));
    }

    public List<Tag> getOrCreateTags(List<String> tagStrings) {
        return tagStrings.stream().map(s -> {
            String[] parts = s.split(":");
            if (parts.length == 2) {
                return getOrCreateTag(parts[1].trim(), parts[0].trim());
            } else {
                return getOrCreateTag(s.trim(), "General");
            }
        }).collect(Collectors.toList());
    }

    public void deleteTag(Long id) {
        tagRepository.deleteById(id);
    }
}
