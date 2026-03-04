-- sample_topics.sql
USE eproject4;

INSERT INTO writing_topic (title, description, hint, image_url, audio_url) VALUES 
('Hometown Introduction', 'Describe your hometown in detail. What are the most interesting places to visit? How has it changed over the years?', 'Recommended structure: 1. Introduction 2. Main attractions 3. Recent changes 4. Conclusion. Remember to use descriptive adjectives like "bustling", "picturesque", or "tranquil".', 'https://images.unsplash.com/photo-1449844908441-8829872d2607?w=800&q=80', NULL);

INSERT INTO writing_topic (title, description, hint, image_url, audio_url) VALUES 
('Technology & Society', 'Some people believe that technology has made our lives too complex. To what extent do you agree or disagree?', 'Consider both sides: How technology simplifies things (communication, information access) vs how it complicates things (constant connectivity, privacy concerns). Ensure you have a clear thesis statement.', 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&q=80', NULL);

INSERT INTO writing_topic (title, description, hint, image_url, audio_url) VALUES 
('Listen and Respond', 'Listen to the attached audio clip discussing environmental conservation efforts. Write an essay summarizing the main points and stating your opinion on their effectiveness.', 'First paragraph: Summary of the audio. Second paragraph: Analysis of the methods discussed. Third paragraph: Your own opinion/evaluation.', NULL, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');

INSERT INTO writing_topic (title, description, hint, image_url, audio_url) VALUES 
('Education System', 'In many countries, schools have severe problems with student behavior. What do you think are the causes of this? What solutions can you suggest?', 'Hint: Focus on causes related to society, parenting, or the educational system itself. For solutions, suggest practical approaches like policy changes or community involvement.', 'https://images.unsplash.com/photo-1577896851231-70ef18881754?w=800&q=80', NULL);

INSERT INTO writing_topic (title, description, hint, image_url, audio_url) VALUES 
('Globalization Impact', 'Is globalization a positive or negative phenomenon? Discuss both views and give your own opinion.', 'Make sure to dedicate one paragraph to the positive aspects (economic growth, cultural exchange) and another to the negative aspects (loss of local culture, economic inequality).', NULL, NULL);
