package com.groupone.backend.features.quizbank.service;

import com.groupone.backend.features.quizbank.entity.Question;
import com.groupone.backend.features.quizbank.enums.DifficultyBand;
import com.groupone.backend.features.quizbank.enums.QuestionType;
import com.groupone.backend.features.quizbank.enums.SkillType;
import com.groupone.backend.features.quizbank.repository.QuestionRepository;
import net.datafaker.Faker;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

@Service
public class DataSeederService {

    @Autowired
    private QuestionRepository questionRepository;

    private static final Random random = new Random();
    private static final Faker faker = new Faker();

    @Transactional
    public void seedQuestions(int count) {
        List<Question> questions = new ArrayList<>();
        SkillType[] skills = SkillType.values();
        QuestionType[] types = QuestionType.values();
        DifficultyBand[] difficulties = DifficultyBand.values();

        for (int i = 1; i <= count; i++) {
            Question q = new Question();
            q.setSkill(skills[random.nextInt(skills.length)]);
            
            QuestionType type = types[random.nextInt(types.length)];
            q.setType(type);
            q.setDifficultyBand(difficulties[random.nextInt(difficulties.length)]);
            
            
            String content = faker.university().name() + ": " + faker.educator().course();
            q.setInstruction(faker.book().title() + " - " + faker.lorem().sentence());
            q.setExplanation("According to " + faker.name().fullName() + ", this relates to " + faker.science().element() + ". " + faker.lorem().paragraph());
            
            
            if (type == QuestionType.MULTIPLE_CHOICE) {
                q.setData(String.format("{\"options\": [\"%s\", \"%s\", \"%s\", \"%s\"], \"correctIndex\": %d}", 
                        faker.word().adjective(), faker.word().adjective(), faker.word().adjective(), faker.word().adjective(), random.nextInt(4)));
            } else {
                q.setData(String.format("{\"content\": \"%s\", \"answer\": \"%s\"}", content, faker.word().noun()));
            }
            
            q.setIsPremiumContent(random.nextBoolean());
            questions.add(q);

            if (i % 50 == 0) {
                questionRepository.saveAll(questions);
                questions.clear();
            }
        }
        
        if (!questions.isEmpty()) {
            questionRepository.saveAll(questions);
        }
    }
}
