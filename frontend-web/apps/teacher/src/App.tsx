import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { PrivateRoute } from "@english-learning/ui";
import TeacherLogin from "./pages/Login";

const queryClient = new QueryClient();

import TeacherDashboard from "./pages/Dashboard";
// Re-using the test page created in admin for testing here as well:
import { QuizBankTestPage } from "../../admin/src/pages/QuizBankTestPage";
import { CategoryPage } from "../../admin/src/pages/questions/CategoryPage";
import { ExamList } from "../../admin/src/pages/questions/ExamList";

function App() {
    return (
        <QueryClientProvider client={queryClient}>
            <BrowserRouter>
                <div className="min-h-screen bg-gray-50">
                    <Routes>
                        <Route path="/" element={<TeacherLogin />} />

                        {/* Protected Routes */}
                        <Route element={<PrivateRoute allowedRole="TEACHER" />}>
                            <Route path="/teacher/dashboard" element={<TeacherDashboard />} />
                            
                            {/* Question Bank Routes */}
                            <Route path="/teacher/questions/vocabulary" element={<CategoryPage skill="VOCABULARY" title="Vocabulary" />} />
                            <Route path="/teacher/questions/listening" element={<CategoryPage skill="LISTENING" title="Listening" />} />
                            <Route path="/teacher/questions/reading" element={<CategoryPage skill="READING" title="Reading" />} />
                            <Route path="/teacher/questions/writing" element={<CategoryPage skill="WRITING" title="Writing" />} />
                            <Route path="/teacher/questions/exam" element={<ExamList />} />
                        </Route>

                        {/* Public Test Route */}
                        <Route path="/teacher/quiz-bank-test" element={<QuizBankTestPage />} />

                        <Route path="*" element={<Navigate to="/" replace />} />
                    </Routes>
                </div>
            </BrowserRouter>
        </QueryClientProvider>
    );
}

export default App;
