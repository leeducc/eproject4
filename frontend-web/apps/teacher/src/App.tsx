import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { PrivateRoute, Toaster } from "@english-learning/ui";
import TeacherLogin from "./pages/Login";

const queryClient = new QueryClient();

import TeacherDashboard from "./pages/Dashboard";
// Re-using the test page created in admin for testing here as well:
import { QuizBankTestPage } from "../../admin/src/pages/QuizBankTestPage";
import { CategoryPage } from "../../admin/src/pages/questions/CategoryPage";
import { QuestionDetailView } from "../../admin/src/pages/questions/QuestionDetailView";
import { QuestionEditPage } from "../../admin/src/pages/questions/QuestionEditPage";
import { ComprehensionDetailView } from "../../admin/src/pages/questions/ComprehensionDetailView";
import { ComprehensionEditPage } from "../../admin/src/pages/questions/ComprehensionEditPage";
import { ExamList } from "../../admin/src/pages/questions/ExamList";
import { TeacherLayout } from "./components/TeacherLayout";
import NotFound from "./pages/NotFound";

function App() {
    return (
        <QueryClientProvider client={queryClient}>
            <Toaster position="top-right" richColors closeButton />
            <BrowserRouter>
                <div className="min-h-screen bg-gray-50">
                    <Routes>
                        <Route path="/" element={<TeacherLogin />} />

                        {/* Protected Routes */}
                        <Route element={<PrivateRoute allowedRole="TEACHER" redirectTo="/" />}>
                            <Route path="/teacher/dashboard" element={<TeacherDashboard />} />
                            
                            {/* Question Bank Routes */}
                            <Route path="/teacher/questions/vocabulary" element={<CategoryPage skill="VOCABULARY" title="Vocabulary" basePath="/teacher" Layout={TeacherLayout} />} />
                            <Route path="/teacher/questions/listening" element={<CategoryPage skill="LISTENING" title="Listening" basePath="/teacher" Layout={TeacherLayout} />} />
                            <Route path="/teacher/questions/reading" element={<CategoryPage skill="READING" title="Reading" basePath="/teacher" Layout={TeacherLayout} />} />
                            <Route path="/teacher/questions/writing" element={<CategoryPage skill="WRITING" title="Writing" basePath="/teacher" Layout={TeacherLayout} />} />
                            <Route path="/teacher/questions/exam" element={<ExamList Layout={TeacherLayout} />} />
                            
                            {/* Detail and Edit Routes */}
                            <Route path="/teacher/questions/:id" element={<QuestionDetailView basePath="/teacher" Layout={TeacherLayout} />} />
                            <Route path="/teacher/questions/:id/edit" element={<QuestionEditPage basePath="/teacher" Layout={TeacherLayout} />} />
                            
                            <Route path="/teacher/comprehensions/:id" element={<ComprehensionDetailView basePath="/teacher" Layout={TeacherLayout} />} />
                            <Route path="/teacher/comprehensions/:id/edit" element={<ComprehensionEditPage basePath="/teacher" Layout={TeacherLayout} />} />
                        </Route>

                        {/* Public Test Route */}
                        <Route path="/teacher/quiz-bank-test" element={<QuizBankTestPage />} />

                        <Route path="*" element={<NotFound />} />
                    </Routes>
                </div>
            </BrowserRouter>
        </QueryClientProvider>
    );
}

export default App;
