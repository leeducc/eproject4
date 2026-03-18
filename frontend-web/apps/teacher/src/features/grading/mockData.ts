import { EssayStatus, EssaySubmission } from "./types";

export const MOCK_ESSAYS: EssaySubmission[] = [
    {
        id: "1",
        studentName: "John Doe",
        taskType: "TASK_2",
        submissionDate: "2024-03-15T10:30:00Z",
        status: EssayStatus.PENDING,
        prompt: "Nowadays, many people use social media to keep in touch with others and get news. Do the advantages of this trend outweigh the disadvantages?",
        content: "In the contemporary era, the proliferation of social media has revolutionised how individuals communicate and access information. While some argue that this trend has detrimental effects on society, I believe that the benefits, such as instant connectivity and democratisation of news, significantly outweigh the drawbacks.\n\nOne of the primary advantages of social media is the ability to maintain relationships regardless of geographical boundaries. In the past, staying in contact with friends or family members who lived abroad was both difficult and expensive. However, platforms like Facebook and WhatsApp allow for real-time interaction, fostering a sense of proximity that was previously unimaginable. This connectivity is particularly beneficial for mental well-being, as it helps combat feelings of isolation among expatriates and students studying far from home.\n\nFurthermore, social media serves as a powerful tool for information dissemination. Unlike traditional media outlets, which may be subject to censorship or corporate bias, social media allows for a diverse range of perspectives to be shared instantly. During major global events, first-hand accounts often emerge on Twitter before they are reported by news agencies, providing a more immediate and multifaceted understanding of the situation. This transparency encourages civic engagement and holds authorities accountable.\n\nOn the other hand, critics point to the spread of misinformation and the potential for social media addiction as significant disadvantages. The rapid sharing of unverified news can lead to public confusion and panic. Moreover, the addictive nature of scrolling through feeds can negatively impact productivity and mental health. However, these issues can be mitigated through digital literacy education and self-regulation.\n\nIn conclusion, while social media does present certain challenges like misinformation, its role in bridging distances and providing accessible information is invaluable. By fostering global connections and empowering voices, the advantages of social media usage clearly surpass its negative aspects.",
    },
    {
        id: "2",
        studentName: "Sarah Smith",
        taskType: "TASK_1",
        submissionDate: "2024-03-16T14:45:00Z",
        status: EssayStatus.IN_PROGRESS,
        lockedBy: "Teacher Emily",
        prompt: "The chart below shows the number of visitors to three different types of museums in London between 2000 and 2015. Summarize the information by selecting and reporting the main features, and make comparisons where relevant.",
        content: "The provided line graph illustrates how many people visited the British Museum, the Science Museum, and the Natural History Museum in London from 2000 to 2015. Overall, it is evident that while the British Museum and the Natural History Museum saw an upward trend in visitor numbers, the Science Museum experienced a fluctuation with an eventual decline.",
    },
    {
        id: "3",
        studentName: "Mike Johnson",
        taskType: "TASK_2",
        submissionDate: "2024-03-16T09:15:00Z",
        status: EssayStatus.GRADED,
        prompt: "Some people think that it is better to educate boys and girls in separate schools. Others, however, believe that mixed schools are more beneficial. Discuss both views and give your opinion.",
        content: "The debate over single-sex versus co-educational schooling has been ongoing for decades. While some proponents argue that separate environments allow for tailored teaching and fewer distractions, I contend that mixed schools are superior as they reflect the reality of society and promote essential social skills.",
        scores: {
            taskAchievement: 7.5,
            taskAchievementReason: "Strong response that addresses all parts of the task. The opinion is clear throughout.",
            cohesionCoherence: 7.0,
            cohesionCoherenceReason: "Good use of cohesive devices, though some paragraph transitions could be smoother.",
            lexicalResource: 8.0,
            lexicalResourceReason: "Wide range of vocabulary used precisely. Very few errors in word choice.",
            grammaticalRange: 7.5,
            grammaticalRangeReason: "A variety of complex structures are used with good control.",
        },
        overallBand: 7.5,
        feedback: "Excellent essay with strong lexical resource. Your argument is well-structured, but ensure that your body paragraphs have more distinct topic sentences.",
        corrections: [
            {
                id: "corr-1",
                start: 110,
                end: 122,
                text: "tailored teaching",
                suggestion: "personalized instruction",
                note: "While 'tailored teaching' is acceptable, 'personalized instruction' sounds more academic in this context."
            }
        ]
    },
    {
        id: "4",
        studentName: "Anna Wong",
        taskType: "TASK_2",
        submissionDate: "2024-03-17T08:00:00Z",
        status: EssayStatus.PENDING,
        prompt: "In many countries, the tradition of having family meals is disappearing. Why is this happening? What are the effects on family life?",
        content: "In the modern fast-paced world, the cherished tradition of families eating together is increasingly becoming a rarity. This trend is primarily driven by hectic work schedules and the rise of digital distractions, resulting in weakened family bonds and poorer nutritional habits.",
    }
];
