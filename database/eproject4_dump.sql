-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: eproject4
-- ------------------------------------------------------
-- Server version	8.0.41

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `essay_submission`
--

DROP TABLE IF EXISTS `essay_submission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `essay_submission` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `ai_feedback` text,
  `content` text NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `grading_type` enum('AI','HUMAN') NOT NULL,
  `score` double DEFAULT NULL,
  `topic_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKs4rk093g0vwn5jfi89ymgkhnb` (`topic_id`),
  CONSTRAINT `FKs4rk093g0vwn5jfi89ymgkhnb` FOREIGN KEY (`topic_id`) REFERENCES `writing_topic` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `essay_submission`
--

LOCK TABLES `essay_submission` WRITE;
/*!40000 ALTER TABLE `essay_submission` DISABLE KEYS */;
INSERT INTO `essay_submission` VALUES (1,'Okay, here’s a detailed assessment of this essay, delivered from the perspective of an IELTS examiner, along with a band score estimate.\n\n**Overall Impression:**\n\nThis is a solid, well-written essay that addresses the prompt effectively. It’s clear, descriptive, and demonstrates a reasonable level of English proficiency. However, there’s room for refinement to elevate the score. The writing leans towards the descriptive side, which is appropriate for this prompt, but the structure and some of the language could be tightened for a more sophisticated response.\n\n**Detailed Feedback:**\n\n**1. Vocabulary (Band Score: 6.5 - 7.0)**\n\n* **Strengths:** The vocabulary is generally appropriate and used correctly. Phrases like “filters through towering pines,” “serene landscape,” “sea of gold and crimson,” and “seeking refuge from the chaos of city life” are well-chosen and create a vivid picture. The use of \"artisanal boutiques\" is also good.\n* **Areas for Improvement:**  There’s a slight tendency towards somewhat cliché descriptions (\"a sanctuary,\" \"progress doesn\'t always have to come at the cost of peace\"). While understandable, aiming for more original and precise wording would strengthen the response.  Consider replacing phrases like “the kind of place” with more specific language.  Also, a slightly broader range of vocabulary would benefit. \n* **Suggestion:**  Encourage the writer to actively look for synonyms and more specific adjectives to avoid repetitive language.\n\n\n**2. Grammar (Band Score: 7.0 - 7.5)**\n\n* **Strengths:** The grammar is largely accurate. Sentences are well-formed, and there are no significant errors in tense, subject-verb agreement, or article usage. The use of relative clauses (“It’s the perfect spot…” and “that has served…”) is handled correctly.\n* **Areas for Improvement:** There\'s a minor issue with slightly repetitive sentence structures (e.g., “It is the kind of place…”). Varying sentence beginnings and lengths would improve flow and demonstrate a more advanced command of grammar. There\'s a slight instance of over-reliance on passive voice (e.g., “those spaces have transitioned”).\n* **Suggestion:** Encourage the writer to consciously vary their sentence structure and consider using active voice where appropriate.\n\n\n**3. Structure & Organisation (Band Score: 6.5 - 7.0)**\n\n* **Strengths:** The essay follows a logical structure: introduction, detailing interesting places, discussing changes over time, and a concluding paragraph.  The paragraphs are clearly delineated and focus on specific aspects of the hometown. The inclusion of specific examples (Old Stone Bridge, Pine Ridge Trail, The Hearth) is a good strategy.\n* **Areas for Improvement:** The “Interesting Places to Visit” section feels slightly disjointed. It’s a list of recommendations rather than a cohesive description that builds upon the overall tone.  The concluding paragraph is a little generic and could be more impactful – perhaps reiterating the key element of balance between development and tradition.\n* **Suggestion:**  Consider weaving the “Interesting Places” descriptions more directly into the broader description of the hometown.  The conclusion should have a stronger sense of closure and reflection.\n\n**4. Coherence and Cohesion (Band Score: 7.0)**\n\n* **Strengths:** The essay demonstrates good coherence through the use of linking words and phrases (e.g., “finally,” “however,” “despite”). The ideas flow reasonably well.\n* **Areas for Improvement:**  Could benefit from more sophisticated linking language to create a more seamless flow.  The transitions between paragraphs could be smoother, particularly between the descriptions of the present and the past.\n* **Suggestion:** Practice using a wider range of cohesive devices to explicitly link ideas and create a more connected argument.\n\n\n\n**Estimated Band Score: 6.5 – 7.0**\n\n**Justification:** This essay shows a solid understanding of the task and demonstrates competence in writing. The grammar and vocabulary are generally accurate, and the structure is logical. However, there\'s potential to elevate the score by refining the language, diversifying sentence structures, and strengthening the overall coherence and impact of the writing.\n\n**Recommendations for the Writer:**\n\n* **Expand Vocabulary:** Explore a thesaurus and actively look for more precise and descriptive words.\n* **Vary Sentence Structure:** Practice sentence combining and varying beginning phrases.\n* **Refine Transitions:**  Experiment with different linking words and phrases to create smoother connections between ideas.\n* **Show, Don’t Tell:**  Instead of saying “it’s a sanctuary,” *show* the reader why it feels like one through more detailed sensory descriptions.\n\n---\n\nDo you want me to provide feedback on another IELTS essay, or perhaps explore a specific aspect of writing in more detail (e.g., how to improve paragraphing)?','My Hometown: A Journey Through Time and Tranquility\nMy hometown is a place where the morning sun filters through towering pines, much like the serene landscape in the image above. Nestled in a quiet valley, it has always been defined by its harmony with nature and its slow, deliberate pace of life. It is the kind of place where neighbors still greet each other by name, and the air carries the crisp scent of damp earth and woodsmoke.\n\nInteresting Places to Visit\nIf you were to visit, the first stop should be the Old Stone Bridge over the Mirror River. It’s the perfect spot for reflection—literally and figuratively. For those who love the outdoors, the Pine Ridge Trail offers a breathtaking panoramic view of the entire valley, especially during the autumn when the leaves transform into a sea of gold and crimson. Finally, no visit is complete without a stop at \"The Hearth,\" a century-old bakery that has served the same secret-recipe cinnamon rolls for generations.\n\nChanges Over the Years\nWhile the town’s soul remains unchanged, the landscape has evolved significantly. Twenty years ago, the outskirts were mostly wild meadows. Today, those spaces have transitioned into sustainable eco-villages and modern cottages that blend into the forest, reflecting a growing community of people seeking refuge from the chaos of city life. The once-dusty main road is now paved, lined with solar-powered streetlights and small, artisanal boutiques.\n\nDespite this modernization, my hometown has successfully preserved its essential character. It remains a sanctuary where the past and the future coexist, proving that progress doesn\'t always have to come at the cost of peace.','2026-03-04 00:44:55.424015','AI',NULL,1),(2,'Okay, here’s a detailed feedback assessment of the essay, as an experienced IELTS examiner would provide.\n\n**Overall Band Score Estimate: 5.5 - 6.0**\n\n**Justification of Band Score:**\n\nThis essay demonstrates a basic understanding of the task and presents a straightforward description of the writer\'s hometown. However, it suffers from limitations in vocabulary, grammatical accuracy, and development of ideas, preventing it from achieving a higher score.  It\'s a reasonable response for a learner at this level but needs significant improvement to reach a 6.5 or 7.0.\n\n**Detailed Feedback:**\n\n**1. Task Response (Band 6.5 - 7.0):**\n\n* **Addresses the Task:** The essay directly addresses the prompt by introducing and describing the writer’s hometown.\n* **Sufficiency of Information:** The description is adequate, providing details about the environment, key places, and some changes. However, it lacks depth and specific examples.  It\'s somewhat generalized.\n* **Focus & Coherence:** The essay maintains a clear focus on the hometown but could benefit from stronger connections between paragraphs. The final paragraph, stating “I love my hometown,” feels a bit tacked on and doesn’t fully integrate with the preceding descriptions.\n\n**2. Vocabulary (Band 5.0 - 5.5):**\n\n* **Range:** The vocabulary is limited. Phrases like “very beautiful and quiet place,” “very cheap,” and “great view” are common and lack precision.\n* **Accuracy:**  Generally accurate, but the language is often simplistic.\n* **Cohesion:**  Vocabulary isn’t used in a particularly sophisticated or nuanced way. There are no noticeable errors in vocabulary usage.\n* **Suggestion for Improvement:**  The writer needs to expand their vocabulary and use more descriptive and precise words. For example, instead of “beautiful and quiet,” they could describe the *types* of trees, the *quality* of the air, or use adjectives like \"tranquil\" or \"serene.\"\n\n**3. Grammar (Band 5.0 - 5.5):**\n\n* **Accuracy:** There are several grammatical errors that slightly impede understanding.\n    * **Repetitive Structures:** \"There are...\" is overused. Varying sentence structures would improve fluency.\n    * **Article Usage:** \"The local market\" is correct, but could be more descriptive (e.g., “the bustling market”).\n    * **Tense Consistency:** Generally consistent, but could be more polished.\n* **Range:** Limited range of grammatical structures.\n* **Suggestion for Improvement:** The writer should focus on varying sentence structure, paying closer attention to correct article usage, and refining the overall grammatical accuracy.  Practicing using more complex sentence structures (e.g., using relative clauses) would be beneficial.\n\n\n**4. Structure & Cohesion (Band 5.5 - 6.0):**\n\n* **Organization:** The essay has a logical structure (introduction, descriptions, changes, conclusion), but transitions between paragraphs could be smoother.\n* **Cohesion:**  Uses linking words (e.g., “First,” “Second,” “Now”) effectively, but could integrate them more seamlessly.\n* **Paragraphing:** Paragraphs are generally well-defined, but the content within each could be more developed.\n* **Suggestion for Improvement:**  The writer should focus on using more sophisticated linking phrases (e.g., \"Furthermore,\" \"In addition,\" \"Consequently\") and ensuring a clear flow of ideas between paragraphs.\n\n**Specific Comments & Suggestions for the Writer:**\n\n* **Expand on Details:** Don\'t just say \"many trees.\" Describe *what kind* of trees, the size of the river, and the surrounding landscape.\n* **Show, Don’t Tell:** Instead of saying \"the people are friendly,\" describe a specific interaction that illustrates this.\n* **Elaborate on Changes:**  Provide more detail about *why* the roads have changed or *what* new shops and supermarkets are like.  What impact has this change had on the town?\n* **Show Personal Connection:** The final paragraph is overly sentimental.  Instead of simply stating “I love my hometown,” try to elaborate on *why* you love it – focusing on specific memories or experiences.\n\n\n**Overall, this is a solid foundation for a more developed essay.  With focused practice on vocabulary, grammar, and developing more detailed and nuanced descriptions, the writer can significantly improve their score.**\n\nDo you want me to:\n\n*   Provide a list of target vocabulary words?\n*   Offer some example sentences demonstrating better grammar structures?\n*   Suggest some specific details the writer could include to enhance the description?','My Hometown\nI want to talk about my hometown. My hometown is a small city in the countryside. It is a very beautiful and quiet place. There are many trees and a big river near my house. The air is very fresh because there are not many cars or factories like in the big city.\n\nThere are some interesting places to visit in my hometown. First, you can go to the local market. In the morning, it is very busy. Many people go there to buy fresh vegetables, fruits, and fish. It is very cheap and the people are friendly. Second, there is a famous old temple on the hill. Many tourists come to see it and take photos because the view is great. You can see the whole city from there.\n\nMy hometown has changed a lot over the years. Ten years ago, the roads were small and made of dirt. Now, the roads are big and modern. There are more shops and a new supermarket now. Before, we didn\'t have many tall buildings, but now there are some small apartments. Even though it is changing, the people are still very kind and helpful.\n\nI love my hometown very much because it is my home. I feel happy when I stay there with my family. I think everyone should visit my hometown one time.','2026-03-04 00:58:19.776540','AI',NULL,1),(3,NULL,'hello','2026-03-04 02:46:03.616551','HUMAN',NULL,1);
/*!40000 ALTER TABLE `essay_submission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `icoin_transactions`
--

DROP TABLE IF EXISTS `icoin_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `icoin_transactions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `amount` int NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `description` text,
  `transaction_type` enum('ADD','DEDUCT','SET') NOT NULL,
  `user_id` bigint NOT NULL,
  `balance_after` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKpyl1theq6fm6ivcsbyh3dlje3` (`user_id`),
  CONSTRAINT `FKpyl1theq6fm6ivcsbyh3dlje3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `icoin_transactions`
--

LOCK TABLES `icoin_transactions` WRITE;
/*!40000 ALTER TABLE `icoin_transactions` DISABLE KEYS */;
INSERT INTO `icoin_transactions` VALUES (1,1000,'2026-03-10 11:33:11.982170','Admin ADD via dashboard','ADD',1,NULL),(2,100,'2026-03-10 11:48:06.535379','Admin ADD via dashboard','ADD',1,1100),(3,1000,'2026-03-11 02:03:03.501122','Payment for: Pro Subscription - 1 months','DEDUCT',1,100);
/*!40000 ALTER TABLE `icoin_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `media_files`
--

DROP TABLE IF EXISTS `media_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `media_files` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `file_size` bigint DEFAULT NULL,
  `mime_type` varchar(255) DEFAULT NULL,
  `original_name` varchar(255) DEFAULT NULL,
  `stored_name` varchar(255) DEFAULT NULL,
  `stored_path` varchar(255) DEFAULT NULL,
  `uploaded_at` datetime(6) DEFAULT NULL,
  `uploaded_by_user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `media_files`
--

LOCK TABLES `media_files` WRITE;
/*!40000 ALTER TABLE `media_files` DISABLE KEYS */;
/*!40000 ALTER TABLE `media_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_profiles`
--

DROP TABLE IF EXISTS `user_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_profiles` (
  `user_id` bigint NOT NULL,
  `avatar_url` varchar(255) DEFAULT NULL,
  `bio` text,
  `full_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `FKjcad5nfve11khsnpwj1mv8frj` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_profiles`
--

LOCK TABLES `user_profiles` WRITE;
/*!40000 ALTER TABLE `user_profiles` DISABLE KEYS */;
INSERT INTO `user_profiles` VALUES (2,NULL,NULL,'Đức Lê'),(3,NULL,NULL,NULL),(5,NULL,NULL,'Teacher 1'),(6,NULL,NULL,'Sample User');
/*!40000 ALTER TABLE `user_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `is_email_confirmed` bit(1) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('ADMIN','CUSTOMER','TEACHER') NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `icoin_balance` int NOT NULL,
  `is_pro` bit(1) NOT NULL,
  `pro_expiry_date` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK6dotkott2kjsp8vw4d0m25fb7` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'2026-03-09 13:43:51.310719','user1@gmail.com',_binary '','$2a$10$8pFxfmvH0/9sGtd.zHDOgO22EoeCqJxJEA1TZm3H7wVCZG2B8LP46','CUSTOMER','2026-03-11 02:03:03.584710',100,_binary '','2026-04-11 02:03:03.561973'),(2,'2026-03-09 14:05:20.818386','leminhduc1212001@gmail.com',_binary '','$2a$10$.9FxrmsxUk2.I4TTbBmmWuOMNOKEV6krm6zdtxAS5uZwIthGh2mp6','CUSTOMER','2026-03-09 14:05:20.819388',0,_binary '\0',NULL),(3,'2026-03-09 17:40:13.967142','duc12012001@gmail.com',_binary '','$2a$10$OB/1Lwp3Cgn0dEFc9dAnMekOOilzf6Ft245GxAqE..RRKQ8Lk8QNS','CUSTOMER','2026-03-09 17:40:13.967650',0,_binary '\0',NULL),(4,'2026-03-10 04:23:43.541626','admin@gmail.com',_binary '','$2a$10$Vke5aaocxbIxYwD3yVAihOBrnzXBjMnorr.4mJw.tiMiAyt3tcStu','ADMIN','2026-03-10 04:23:43.541626',0,_binary '\0',NULL),(5,'2026-03-10 04:26:52.374083','teacher1@gmail.com',_binary '','$2a$10$3HmJGMi6Dz0ZchPy1/b0G.nZ2pZjH57cNlFqEdKuS2Fs4o8hnT/gu','TEACHER','2026-03-10 04:26:52.374083',0,_binary '\0',NULL),(6,'2026-03-11 02:17:18.108572','user2@gmail.com',_binary '','$2a$10$AL.aHXIIboVUQh4zzX4jiO0cqDTuac5Z59fBEwqDn5rYKinDSPdEO','CUSTOMER','2026-03-11 02:17:18.108572',0,_binary '\0',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `writing_topic`
--

DROP TABLE IF EXISTS `writing_topic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `writing_topic` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` text,
  `title` varchar(255) NOT NULL,
  `audio_url` varchar(255) DEFAULT NULL,
  `hint` text,
  `image_url` varchar(255) DEFAULT NULL,
  `is_pro_only` bit(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `writing_topic`
--

LOCK TABLES `writing_topic` WRITE;
/*!40000 ALTER TABLE `writing_topic` DISABLE KEYS */;
INSERT INTO `writing_topic` VALUES (1,'Describe your hometown in detail. What are the most interesting places to visit? How has it changed over the years?','Hometown Introduction',NULL,'Recommended structure: 1. Introduction 2. Main attractions 3. Recent changes 4. Conclusion. Remember to use descriptive adjectives like \"bustling\", \"picturesque\", or \"tranquil\".','https://images.unsplash.com/photo-1449844908441-8829872d2607?w=800&q=80',_binary '\0'),(2,'Some people believe that technology has made our lives too complex. To what extent do you agree or disagree?','Technology & Society',NULL,'Consider both sides: How technology simplifies things (communication, information access) vs how it complicates things (constant connectivity, privacy concerns). Ensure you have a clear thesis statement.','https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&q=80',_binary ''),(3,'Listen to the attached audio clip discussing environmental conservation efforts. Write an essay summarizing the main points and stating your opinion on their effectiveness.','Listen and Respond','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3','First paragraph: Summary of the audio. Second paragraph: Analysis of the methods discussed. Third paragraph: Your own opinion/evaluation.',NULL,_binary ''),(4,'In many countries, schools have severe problems with student behavior. What do you think are the causes of this? What solutions can you suggest?','Education System',NULL,'Hint: Focus on causes related to society, parenting, or the educational system itself. For solutions, suggest practical approaches like policy changes or community involvement.','https://images.unsplash.com/photo-1577896851231-70ef18881754?w=800&q=80',_binary ''),(5,'Is globalization a positive or negative phenomenon? Discuss both views and give your own opinion.','Globalization Impact',NULL,'Make sure to dedicate one paragraph to the positive aspects (economic growth, cultural exchange) and another to the negative aspects (loss of local culture, economic inequality).',NULL,_binary '');
/*!40000 ALTER TABLE `writing_topic` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-11 10:14:32
