package com.groupone.backend.features.vocabulary;

import com.groupone.backend.features.identity.User;
import com.groupone.backend.features.identity.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class VocabularyTestService {

    private final UserWordProgressRepository progressRepository;
    private final VocabularyRepository vocabularyRepository;
    private final VocabularyPracticeAiContentRepository practiceRepository;
    private final UserRepository userRepository;
    private final AiContentService aiContentService;
    private final Random random = new Random();

    @Transactional
    public VocabularyTestDTO generateTest(Long userId) {
        log.info("Generating daily test for user ID: {}", userId);
        
        List<Long> selectedVocabIds = new ArrayList<>();
        
        
        List<UserWordProgress> dueForReview = progressRepository.findDueForReview(userId, LocalDateTime.now());
        Collections.shuffle(dueForReview);
        dueForReview.stream().limit(6).forEach(p -> selectedVocabIds.add(p.getVocabulary().getId()));
        
        
        int weakLimit = 2;
        if (selectedVocabIds.size() < 6) weakLimit += (6 - selectedVocabIds.size()); 
        
        List<UserWordProgress> weakWords = progressRepository.findWeakWords(userId).stream()
                .filter(p -> !selectedVocabIds.contains(p.getVocabulary().getId()))
                .collect(Collectors.toList());
        Collections.shuffle(weakWords);
        weakWords.stream().limit(weakLimit).forEach(p -> selectedVocabIds.add(p.getVocabulary().getId()));
        
        
        int remainingSlots = 10 - selectedVocabIds.size();
        if (remainingSlots > 0) {
            List<UserWordProgress> viewedNotTested = progressRepository.findViewedButNotTested(userId);
            Collections.shuffle(viewedNotTested);
            viewedNotTested.stream().limit(remainingSlots).forEach(p -> selectedVocabIds.add(p.getVocabulary().getId()));
        }
        
        
        remainingSlots = 10 - selectedVocabIds.size();
        if (remainingSlots > 0) {
            List<Long> newWordIds = progressRepository.findNewWordIds(userId, remainingSlots);
            selectedVocabIds.addAll(newWordIds);
        }

        
        List<TestQuestionDTO> questions = selectedVocabIds.stream()
                .map(id -> {
                    VocabularyEntity vocab = vocabularyRepository.findById(id).orElse(null);
                    if (vocab == null) return null;
                    
                    List<VocabularyPracticeAiContentEntity> practices = practiceRepository.findAllByWord(vocab.getWord());
                    
                    
                    if (practices.isEmpty()) {
                        log.info("No practice questions found for word: '{}'. Generating on the fly...", vocab.getWord());
                        try {
                            aiContentService.generatePractice(vocab.getWord());
                            practices = practiceRepository.findAllByWord(vocab.getWord());
                        } catch (Exception e) {
                            log.error("Failed to generate practice for word '{}': {}", vocab.getWord(), e.getMessage());
                        }
                    }

                    if (practices.isEmpty()) {
                        log.warn("Still no practice questions for word: {}", vocab.getWord());
                        return null;
                    }
                    
                    VocabularyPracticeAiContentEntity practice = practices.get(random.nextInt(practices.size()));
                    return TestQuestionDTO.builder()
                            .id(vocab.getId())
                            .word(vocab.getWord())
                            .quizType(practice.getQuizType())
                            .questionJson(practice.getJsonContent())
                            .build();
                })
                .filter(q -> q != null)
                .collect(Collectors.toList());

        return VocabularyTestDTO.builder().questions(questions).build();
    }

    @Transactional(readOnly = true)
    public int getDueCount(Long userId) {
        return progressRepository.findDueForReview(userId, LocalDateTime.now()).size();
    }

    @Transactional
    public void logView(Long userId, Long vocabularyId) {
        log.info("Logging view for user ID: {}, vocabulary ID: {}", userId, vocabularyId);
        progressRepository.findByUserIdAndVocabularyId(userId, vocabularyId)
                .ifPresentOrElse(
                    p -> {
                        p.setViewed(true);
                        progressRepository.save(p);
                    },
                    () -> {
                        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
                        VocabularyEntity vocab = vocabularyRepository.findById(vocabularyId).orElseThrow(() -> new RuntimeException("Vocabulary not found"));
                        UserWordProgress progress = UserWordProgress.builder()
                                .user(user)
                                .vocabulary(vocab)
                                .isViewed(true)
                                .proficiencyLevel(0)
                                .correctStreak(0)
                                .build();
                        progressRepository.save(progress);
                    }
                );
    }

    @Transactional
    public void submitResults(Long userId, VocabularyTestSubmissionDTO submission) {
        log.info("Submitting test results for user ID: {}", userId);
        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
        
        for (AnswerDTO answer : submission.getAnswers()) {
            UserWordProgress progress = progressRepository.findByUserIdAndVocabularyId(userId, answer.getVocabularyId())
                    .orElseGet(() -> {
                        VocabularyEntity vocab = vocabularyRepository.findById(answer.getVocabularyId())
                                .orElseThrow(() -> new RuntimeException("Vocabulary not found"));
                        return UserWordProgress.builder()
                                .user(user)
                                .vocabulary(vocab)
                                .proficiencyLevel(0)
                                .correctStreak(0)
                                .build();
                    });

            if (answer.isCorrect()) {
                progress.setCorrectStreak(progress.getCorrectStreak() + 1);
                progress.setProficiencyLevel(Math.min(5, progress.getProficiencyLevel() + 1));
                
                
                int daysToAdd = switch (progress.getCorrectStreak()) {
                    case 1 -> 1;
                    case 2 -> 3;
                    case 3 -> 7;
                    case 4 -> 14;
                    default -> 30;
                };
                progress.setNextReviewDate(LocalDateTime.now().plusDays(daysToAdd));
            } else {
                progress.setCorrectStreak(0);
                progress.setProficiencyLevel(Math.max(0, progress.getProficiencyLevel() - 1));
                progress.setNextReviewDate(LocalDateTime.now().plusDays(1)); 
            }
            
            progress.setLastReviewedAt(LocalDateTime.now());
            progressRepository.save(progress);
        }
    }
}
