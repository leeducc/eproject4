import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuizBankStore } from '../../features/quiz-bank/store';
import { QuestionGroup } from '../../features/quiz-bank/types';
import { toast } from '@english-learning/ui';
import { AdminLayout } from '../../components/AdminLayout';
import { ArrowLeft, BookOpen } from 'lucide-react';
import { ComprehensionBuilder } from '../../features/quiz-bank/components/ComprehensionBuilder';

export const ComprehensionEditPage: React.FC<{ basePath?: string, Layout?: React.ComponentType<{ children: React.ReactNode }> }> = ({ basePath = '/admin', Layout = AdminLayout }) => {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    const { fetchGroupById, isLoading } = useQuizBankStore();
    const [group, setGroup] = useState<QuestionGroup | null>(null);

    useEffect(() => {
        if (id) {
            console.log(`[ComprehensionEditPage] Fetching group ID for editing: ${id}`);
            fetchGroupById(parseInt(id)).then(g => {
                if (g) setGroup(g);
                else {
                    toast.error("Comprehension not found");
                    navigate(-1);
                }
            });
        }
    }, [id, fetchGroupById, navigate]);

    if (isLoading && !group) {
        return (
            <Layout>
                <div className="flex items-center justify-center h-64">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                </div>
            </Layout>
        );
    }

    if (!group) return null;

    const handleSaveComplete = () => {
        toast.success("Comprehension updated successfully");
        navigate(`${basePath}/comprehensions/${id}`);
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
                    <h1 className="text-2xl font-bold text-gray-900 dark:text-slate-100 flex items-center gap-3">
                        <BookOpen className="text-purple-600" />
                        Editing Comprehension Passage
                        <span className="text-gray-400 dark:text-slate-500 ml-2 font-normal text-lg">ID: #{id}</span>
                    </h1>
                </div>

                <div className="bg-white dark:bg-slate-900 rounded-2xl border border-gray-200 dark:border-slate-800 shadow-sm p-6 md:p-10 transition-colors">
                    <div className="mb-10 pb-6 border-b border-gray-100 dark:border-slate-800">
                        <p className="text-gray-500 dark:text-slate-400 text-sm">
                            Modify the passage content, title, and child questions below. All changes will be saved as a single unit.
                        </p>
                    </div>

                    <ComprehensionBuilder 
                        initialGroup={group} 
                        onSave={handleSaveComplete} 
                    />
                </div>
            </div>
        </Layout>
    );
};
