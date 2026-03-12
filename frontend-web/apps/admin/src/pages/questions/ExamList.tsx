import React, { useState, useEffect } from 'react';
import { useQuizBankStore } from '../../features/quiz-bank/store';
import { DashboardLayout, NavItem } from '@english-learning/ui';
import { Home, Database, Users, Settings, Briefcase, Plus, Trash2, Edit2, BookOpen } from 'lucide-react';
import { ExamCompositionUI } from '../../features/quiz-bank/components/ExamCompositionUI';

export const ExamList: React.FC = () => {
  const { exams, currentUser, deleteExam, fetchExams } = useQuizBankStore();
  const [isCreating, setIsCreating] = useState(false);

  const isTeacher = currentUser.role === 'TEACHER';

  useEffect(() => {
    fetchExams();
  }, [fetchExams]);

  // Define sidebar locally just to render DashboardLayout generically per standard practices
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

  return (
    <DashboardLayout sidebarItems={sidebarItems} userName={currentUser.name} userRole={currentUser.role === 'ADMIN' ? 'System Admin' : 'Teacher'}>
      <div className="flex flex-col gap-6 max-w-7xl mx-auto py-6">
        
        <div className="flex items-center justify-between">
            <div>
                <h1 className="text-2xl font-bold text-gray-800">Exam Management</h1>
                <p className="text-sm text-gray-500 mt-1">Assemble, view, and manage available exams.</p>
            </div>
            {!isCreating && (
                <button 
                  onClick={() => setIsCreating(true)}
                  className="bg-primary hover:bg-primary/90 text-white px-4 py-2 rounded-lg text-sm font-medium flex items-center gap-2 transition-colors"
                >
                  <Plus size={16} /> Assemble New Exam
                </button>
            )}
        </div>

        {isCreating ? (
            <div className="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                <div className="flex items-center justify-between mb-6">
                    <h2 className="text-xl font-bold text-gray-800 w-full border-b pb-4">Exam Composer</h2>
                    <button 
                        onClick={() => setIsCreating(false)}
                        className="text-sm text-gray-500 hover:text-gray-700 underline absolute top-6 right-6"
                        style={{marginTop: "5px"}}
                    >
                        Cancel & Return
                    </button>
                </div>
                {/* Embed the Exam Composition interface */}
                <ExamCompositionUI onSave={() => setIsCreating(false)} />
            </div>
        ) : (
            <div className="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                <table className="w-full text-left border-collapse">
                    <thead>
                        <tr className="bg-gray-50 border-b border-gray-100 text-gray-500 text-xs uppercase tracking-wider">
                            <th className="p-4 font-semibold">ID</th>
                            <th className="p-4 font-semibold">Exam Title</th>
                            <th className="p-4 font-semibold">Questions</th>
                            <th className="p-4 font-semibold">Categories Included</th>
                            <th className="p-4 font-semibold">Created</th>
                            <th className="p-4 font-semibold text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                        {exams.length === 0 ? (
                            <tr>
                                <td colSpan={6} className="p-12 text-center text-gray-500">
                                    <BookOpen className="mx-auto h-12 w-12 text-gray-300 mb-3" />
                                    <p className="font-medium text-gray-600">No Exams found.</p>
                                    <p className="text-sm mt-1">Click the "Assemble New Exam" button to aggregate questions.</p>
                                </td>
                            </tr>
                        ) : (
                            exams.map((exam) => (
                                <tr key={exam.id} className="hover:bg-gray-50/50 transition-colors">
                                    <td className="p-4 text-sm font-medium text-gray-900 border-b border-gray-100">#{exam.id.toString().slice(-4)}</td>
                                    
                                    <td className="p-4 text-sm font-bold text-gray-800 border-b border-gray-100 w-1/3">
                                        {exam.title}
                                    </td>
                                    
                                    <td className="p-4 text-sm text-gray-600 border-b border-gray-100 font-bold">
                                        {exam.question_ids.length}
                                    </td>
                                    
                                    <td className="p-4 text-sm border-b border-gray-100">
                                       <div className="flex gap-1 flex-wrap w-full">
                                          {exam.categories.map(cat => (
                                              <span key={cat} className="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold border border-gray-200 bg-gray-50 text-gray-600">
                                                  {cat}
                                              </span>
                                          ))}
                                       </div>
                                    </td>

                                    <td className="p-4 text-sm text-gray-500 border-b border-gray-100">
                                        {exam.created_at}
                                    </td>

                                    <td className="p-4 text-right border-b border-gray-100">
                                        <div className="flex items-center justify-end gap-2">
                                            <button className="p-1.5 text-gray-400 hover:text-blue-600 rounded bg-white mt-1 border shadow-sm transition-colors">
                                                <Edit2 size={16} />
                                            </button>
                                            
                                            {/* RBAC Rules again: hide Deletes for TEACHER role */}
                                            {!isTeacher && (
                                                <button 
                                                    onClick={() => deleteExam(exam.id)}
                                                    className="p-1.5 text-gray-400 hover:text-red-600 rounded bg-white border mt-1 shadow-sm transition-colors"
                                                >
                                                    <Trash2 size={16} />
                                                </button>
                                            )}
                                        </div>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>
        )}
      </div>
    </DashboardLayout>
  );
};
