import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuizBankStore } from '../../features/quiz-bank/store';
import { Question } from '../../features/quiz-bank/types';
import { toast } from '@english-learning/ui';
import { ArrowLeft } from 'lucide-react';
import { MultipleChoiceBuilder } from '../../features/quiz-bank/components/MultipleChoiceBuilder';
import { FillInTheBlankBuilder } from '../../features/quiz-bank/components/FillInTheBlankBuilder';
import { MatchingBuilder } from '../../features/quiz-bank/components/MatchingBuilder';
import { WritingBuilder } from '../../features/quiz-bank/components/WritingBuilder';
import { AdminLayout } from '../../components/AdminLayout';

interface QuestionEditPageProps {
    basePath?: string;
    Layout?: React.ComponentType<{ children: React.ReactNode }>;
}

export const QuestionEditPage: React.FC<QuestionEditPageProps> = ({
    basePath = '/admin',
    Layout = AdminLayout
}) => {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    const { fetchQuestionById, isLoading } = useQuizBankStore();
    const [question, setQuestion] = useState<Question | null>(null);

    useEffect(() => {
        if (id) {
            console.log(`[QuestionEditPage] Fetching question ID for editing: ${id}`);
            fetchQuestionById(parseInt(id)).then(q => {
                if (q) setQuestion(q);
                else {
                    toast.error("Question not found");
                    navigate(-1);
                }
            });
        }
    }, [id, fetchQuestionById, navigate]);

    if (isLoading && !question) {
        return (
            <Layout>
                <div className="flex items-center justify-center h-64">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                </div>
            </Layout>
        );
    }

    if (!question) return null;

    const handleSaveComplete = () => {
        toast.success("Question updated successfully");
        navigate(`${basePath}/questions/${id}`);
    };

    return (
        <Layout>
            <div className="max-w-6xl mx-auto py-8 px-4">
                <div className="mb-8">
                    <button 
                        onClick={() => navigate(-1)}
                        className="flex items-center gap-1 text-sm text-blue-600 hover:text-blue-700 font-medium mb-2"
                    >
                        <ArrowLeft size={16} /> Cancel and Go Back
                    </button>
                    <h1 className="text-2xl font-bold text-gray-900 dark:text-slate-100">
                        Editing {question.type.replace('_', ' ')} Question 
                        <span className="text-gray-400 dark:text-slate-500 ml-2 font-normal text-lg">ID: #{id}</span>
                    </h1>
                </div>

                <div className="bg-white dark:bg-slate-900 rounded-2xl border border-gray-200 dark:border-slate-800 shadow-sm p-6 md:p-10 transition-colors">
                    <div className="mb-10 pb-6 border-b border-gray-100 dark:border-slate-800 flex items-center justify-between">
                         <div>
                            <p className="text-gray-500 dark:text-slate-400 text-sm">Update the fields below and save to apply changes. All modifications will reflect immediately on the detail view.</p>
                         </div>
                    </div>

                    {question.skill === 'WRITING' || question.type === 'ESSAY' ? (
                        <WritingBuilder 
                            initialQuestion={question} 
                            onSave={handleSaveComplete} 
                        />
                    ) : question.type === 'MULTIPLE_CHOICE' ? (
                        <MultipleChoiceBuilder 
                            skill={question.skill} 
                            initialQuestion={question} 
                            onSave={handleSaveComplete} 
                        />
                    ) : question.type === 'MATCHING' ? (
                        <MatchingBuilder 
                            skill={question.skill} 
                            initialQuestion={question} 
                            onSave={handleSaveComplete} 
                        />
                    ) : (
                        <FillInTheBlankBuilder 
                            skill={question.skill} 
                            initialQuestion={question} 
                            onSave={handleSaveComplete} 
                        />
                    )}
                </div>
            </div>
        </Layout>
    );
};
