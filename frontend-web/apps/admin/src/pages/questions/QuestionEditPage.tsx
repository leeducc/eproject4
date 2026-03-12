import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuizBankStore } from '../../features/quiz-bank/store';
import { Question } from '../../features/quiz-bank/types';
import { DashboardLayout, NavItem, toast } from '@english-learning/ui';
import { ArrowLeft, Home, Database, Briefcase, Users, Settings } from 'lucide-react';
import { MultipleChoiceBuilder } from '../../features/quiz-bank/components/MultipleChoiceBuilder';
import { FillInTheBlankBuilder } from '../../features/quiz-bank/components/FillInTheBlankBuilder';
import { MatchingBuilder } from '../../features/quiz-bank/components/MatchingBuilder';
import { WritingBuilder } from '../../features/quiz-bank/components/WritingBuilder';

const sidebarItems: NavItem[] = [
    { title: "Dashboard Overview", href: "/admin/dashboard", icon: <Home size={20} /> },
    {
        title: "Questions Bank",
        icon: <Database size={20} />,
        children: [
            { title: "Vocabulary", href: "/admin/questions/vocabulary" },
            { title: "Listening", href: "/admin/questions/listening" },
            { title: "Reading", href: "/admin/questions/reading" },
            { title: "Writing", href: "/admin/questions/writing" },
            { title: "Exam", href: "/admin/questions/exam" },
        ],
    },
    {
        title: "Teacher Management",
        icon: <Briefcase size={20} />,
        children: [
            { title: "Teacher List", href: "/admin/teachers/list" },
            { title: "Performance & Logs", href: "/admin/teachers/logs" },
        ],
    },
    {
        title: "Customer Management",
        icon: <Users size={20} />,
        children: [
            { title: "Customer List", href: "/admin/customers/list" },
            { title: "Messages", href: "/admin/customers/messages" },
            { title: "Reports", href: "/admin/customers/reports" },
            { title: "Requests", href: "/admin/customers/requests" },
            { title: "iCoin Transactions", href: "/admin/customer-management/icoin" },
        ],
    },
    { title: "App Management", href: "/admin/settings", icon: <Settings size={20} /> },
];

export const QuestionEditPage: React.FC = () => {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    const { fetchQuestionById, currentUser, isLoading } = useQuizBankStore();
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
            <DashboardLayout sidebarItems={sidebarItems} userName={currentUser.name} userRole={currentUser.role === 'ADMIN' ? 'System Admin' : 'Teacher'}>
                <div className="flex items-center justify-center h-64">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                </div>
            </DashboardLayout>
        );
    }

    if (!question) return null;

    const handleSaveComplete = () => {
        toast.success("Question updated successfully");
        navigate(`/admin/questions/${id}`);
    };

    return (
        <DashboardLayout sidebarItems={sidebarItems} userName={currentUser.name} userRole={currentUser.role === 'ADMIN' ? 'System Admin' : 'Teacher'}>
            <div className="max-w-6xl mx-auto py-8 px-4">
                <div className="mb-8">
                    <button 
                        onClick={() => navigate(-1)}
                        className="flex items-center gap-1 text-sm text-blue-600 hover:text-blue-700 font-medium mb-2"
                    >
                        <ArrowLeft size={16} /> Cancel and Go Back
                    </button>
                    <h1 className="text-2xl font-bold text-gray-900">
                        Editing {question.type.replace('_', ' ')} Question 
                        <span className="text-gray-400 ml-2 font-normal text-lg">ID: #{id}</span>
                    </h1>
                </div>

                <div className="bg-white rounded-2xl border border-gray-200 shadow-sm p-6 md:p-10">
                    <div className="mb-10 pb-6 border-b border-gray-100 flex items-center justify-between">
                         <div>
                            <p className="text-gray-500 text-sm">Update the fields below and save to apply changes. All modifications will reflect immediately on the detail view.</p>
                         </div>
                    </div>

                    {question.type === 'ESSAY' ? (
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
        </DashboardLayout>
    );
};
