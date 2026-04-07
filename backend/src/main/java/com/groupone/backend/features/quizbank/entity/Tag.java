package com.groupone.backend.features.quizbank.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "qb_tags")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Tag {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String namespace; 

    private String color; 
}
