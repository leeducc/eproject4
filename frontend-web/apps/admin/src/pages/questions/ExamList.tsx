import React, { useState, useEffect } from 'react';
import { useQuizBankStore } from '../../features/quiz-bank/store';
import { ConfirmDialog, toast } from '@english-learning/ui';
import { Plus, Trash2, Edit2, BookOpen, ArrowLeft, Eye } from 'lucide-react';
import { ExamCompositionUI } from '../../features/quiz-bank/components/ExamCompositionUI';
import { AdminLayout } from '../../components/AdminLayout';

export const ExamList: React.FC<{
  Layout?: React.ComponentType<{ children: React.ReactNode }>
}> = ({ Layout = AdminLayout }) => {
  const { exams, currentUser, deleteExam, fetchExams } = useQuizBankStore();
  const [isCreating, setIsCreating] = useState(false);
  const [examToDelete, setExamToDelete] = useState<number | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [editingId, setEditingId] = useState<number | undefined>(undefined);
  const [viewMode, setViewMode] = useState<'EDIT' | 'VIEW'>('EDIT');

  const isTeacher = currentUser.role === 'TEACHER';

  const handleConfirmDelete = async () => {
    if (examToDelete) {
      try {
        await deleteExam(examToDelete);
        toast.success("Exam deleted successfully");
      } catch (error) {
        toast.error("Failed to delete exam");
      } finally {
        setExamToDelete(null);
      }
    }
  };

  useEffect(() => {
    fetchExams();
  }, [fetchExams]);

  // Route protection / Reset
  useEffect(() => {
    console.log('[ExamList] Route changed (%s), resetting view state.', window.location.pathname);
    setIsCreating(false);
    setIsEditing(false);
    setEditingId(undefined);
  }, [window.location.pathname]);

  const handleEdit = (id: number) => {
    setEditingId(id);
    setViewMode('EDIT');
    setIsEditing(true);
  };

  const handleView = (id: number) => {
    setEditingId(id);
    setViewMode('VIEW');
    setIsEditing(true);
  };

  if (isCreating) {
    return (
      <Layout>
        <div className="p-6">
          <div className="flex items-center gap-4 mb-8">
             <button 
               onClick={() => setIsCreating(false)}
               className="p-2 hover:bg-gray-100 dark:hover:bg-slate-800 rounded-full transition-colors text-gray-500"
             >
               <ArrowLeft size={20} />
             </button>
             <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Assemble New Exam</h1>
          </div>
          <ExamCompositionUI onSave={() => setIsCreating(false)} />
        </div>
      </Layout>
    );
  }

  if (isEditing && editingId) {
    return (
      <Layout>
        <div className="p-6">
          <div className="flex items-center gap-4 mb-8">
             <button 
               onClick={() => { setIsEditing(false); setEditingId(undefined); }}
               className="p-2 hover:bg-gray-100 dark:hover:bg-slate-800 rounded-full transition-colors text-gray-500"
             >
              <ArrowLeft size={20} />
             </button>
             <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
               {viewMode === 'VIEW' ? 'Exam Details' : 'Edit Exam'}
             </h1>
          </div>
          <ExamCompositionUI 
            onSave={() => { setIsEditing(false); setEditingId(undefined); fetchExams(); }} 
            examId={editingId}
            mode={viewMode}
          />
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className="flex flex-col gap-6 max-w-7xl mx-auto py-6">
        
        <div className="flex items-center justify-between">
            <div>
                <h1 className="text-2xl font-bold text-gray-800 dark:text-slate-100">Exam Management</h1>
                <p className="text-sm text-gray-500 dark:text-slate-400 mt-1">Assemble, view, and manage available exams.</p>
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
            <div className="bg-white dark:bg-slate-900 p-6 rounded-xl border border-gray-200 dark:border-slate-800 shadow-sm transition-colors">
                <div className="flex items-center justify-between mb-6">
                    <h2 className="text-xl font-bold text-gray-800 dark:text-slate-100 w-full border-b dark:border-slate-800 pb-4">Exam Composer</h2>
                    <button 
                        onClick={() => setIsCreating(false)}
                        className="text-sm text-gray-500 dark:text-slate-400 hover:text-gray-700 dark:hover:text-slate-200 underline absolute top-6 right-6"
                        style={{marginTop: "5px"}}
                    >
                        Cancel & Return
                    </button>
                </div>
                {/* Embed the Exam Composition interface */}
                <ExamCompositionUI onSave={() => setIsCreating(false)} />
            </div>
        ) : (
            <div className="bg-white dark:bg-slate-900 rounded-xl border border-gray-200 dark:border-slate-800 shadow-sm overflow-hidden transition-colors">
                <table className="w-full text-left border-collapse">
                    <thead>
                        <tr className="bg-gray-50 dark:bg-slate-800/50 border-b border-gray-100 dark:border-slate-800 text-gray-500 dark:text-slate-400 text-xs uppercase tracking-wider">
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
                                <td colSpan={6} className="p-12 text-center text-gray-500 dark:text-slate-500">
                                    <BookOpen className="mx-auto h-12 w-12 text-gray-300 dark:text-slate-700 mb-3" />
                                    <p className="font-medium text-gray-600 dark:text-slate-400">No Exams found.</p>
                                    <p className="text-sm mt-1">Click the "Assemble New Exam" button to aggregate questions.</p>
                                </td>
                            </tr>
                        ) : (
                            exams.map((exam) => (
                                <tr key={exam.id} className="hover:bg-gray-50/50 dark:hover:bg-slate-800/30 transition-colors">
                                    <td className="p-4 text-sm font-medium text-gray-900 dark:text-slate-300 border-b border-gray-100 dark:border-slate-800">#{exam.id.toString().slice(-4)}</td>
                                    
                                    <td className="p-4 text-sm font-bold text-gray-800 dark:text-slate-200 border-b border-gray-100 dark:border-slate-800 w-1/3">
                                        <h3 
                                               className="font-bold text-gray-900 dark:text-white group-hover:text-primary transition-colors cursor-pointer"
                                               onClick={() => handleView(exam.id)}
                                             >
                                               {exam.title}
                                             </h3>
                                    </td>
                                    
                                    <td className="p-4 text-sm text-gray-600 dark:text-slate-400 border-b border-gray-100 dark:border-slate-800 font-bold">
                                        {exam.question_ids.length}
                                    </td>
                                    
                                    <td className="p-4 text-sm border-b border-gray-100 dark:border-slate-800">
                                       <div className="flex gap-1 flex-wrap w-full">
                                          {exam.categories.map(cat => (
                                              <span key={cat} className="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold border border-gray-200 dark:border-slate-700 bg-gray-50 dark:bg-slate-800 text-gray-600 dark:text-slate-400">
                                                  {cat}
                                              </span>
                                          ))}
                                       </div>
                                    </td>

                                    <td className="p-4 text-sm text-gray-500 dark:text-slate-500 border-b border-gray-100 dark:border-slate-800">
                                        {exam.created_at}
                                    </td>

                                    <td className="p-4 text-right border-b border-gray-100 dark:border-slate-800">
                                        <div className="flex items-center justify-end gap-2">
                                            <button 
                                               onClick={() => handleView(exam.id)}
                                               className="p-1.5 text-gray-400 dark:text-slate-500 hover:text-primary dark:hover:text-primary rounded bg-white dark:bg-slate-800 mt-1 border dark:border-slate-700 shadow-sm transition-colors"
                                               title="View Details"
                                             >
                                                 <Eye size={16} />
                                             </button>
                                            <button 
                                                onClick={() => handleEdit(exam.id)}
                                                className="p-1.5 text-gray-400 dark:text-slate-500 hover:text-blue-600 dark:hover:text-blue-400 rounded bg-white dark:bg-slate-800 mt-1 border dark:border-slate-700 shadow-sm transition-colors"
                                                title="Edit Exam"
                                            >
                                                <Edit2 size={16} />
                                            </button>
                                            
                                            {/* RBAC Rules again: hide Deletes for TEACHER role */}
                                            {!isTeacher && (
                                                <button 
                                                    onClick={() => setExamToDelete(exam.id)}
                                                    className="p-1.5 text-gray-400 dark:text-slate-500 hover:text-red-600 dark:hover:text-red-400 rounded bg-white dark:bg-slate-800 border dark:border-slate-700 mt-1 shadow-sm transition-colors"
                                                    title="Delete Exam"
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

      <ConfirmDialog
        isOpen={examToDelete !== null}
        onClose={() => setExamToDelete(null)}
        onConfirm={handleConfirmDelete}
        title="Delete Exam"
        message="Are you sure you want to delete this exam? This action cannot be undone."
        confirmText="Delete"
        variant="danger"
      />
    </Layout>
  );
};
