export enum EssayStatus {
    PENDING = 'PENDING',
    IN_PROGRESS = 'IN_PROGRESS',
    GRADED = 'GRADED',
}

export type TaskType = 'TASK_1' | 'TASK_2';

export interface Correction {
    id: string;
    start: number;
    end: number;
    text: string;
    suggestion?: string;
    note?: string;
}

export interface IELTSScores {
    taskAchievement: number;
    taskAchievementReason?: string;
    cohesionCoherence: number;
    cohesionCoherenceReason?: string;
    lexicalResource: number;
    lexicalResourceReason?: string;
    grammaticalRange: number;
    grammaticalRangeReason?: string;
}

export interface EssaySubmission {
    id: string;
    studentName: string;
    taskType: TaskType;
    submissionDate: string;
    status: EssayStatus;
    lockedBy?: string;
    lockedById?: string;
    content: string;
    prompt: string;
    scores?: IELTSScores;
    overallBand?: number;
    feedback?: string;
    corrections?: Correction[];
}
