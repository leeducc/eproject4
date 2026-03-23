import { z } from "zod";

export const QuestionSchema = z.object({
    id: z.string().uuid().optional(),
    title: z.string().min(5, "Question title must be at least 5 characters"),
    options: z.array(z.string()).min(2, "Must have at least 2 options"),
    correctOptionIndex: z.number().int().min(0),
    difficulty: z.enum(["easy", "medium", "hard"]),
});

export type Question = z.infer<typeof QuestionSchema>;

export interface QuestionHistory {
    id: number;
    questionId: number;
    editorId: number;
    editorEmail: string;
    action: string;
    snapshot: string;
    createdAt: string;
}
