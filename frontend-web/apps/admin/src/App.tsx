import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { PrivateRoute } from "@english-learning/ui";
import AdminLogin from "./pages/Login";

const queryClient = new QueryClient();

import AdminDashboard from "./pages/Dashboard";
import ICoinManagement from "./pages/ICoinManagement";
import { QuizBankTestPage } from "./pages/QuizBankTestPage";
import { CategoryPage } from "./pages/questions/CategoryPage";
import { ExamList } from "./pages/questions/ExamList";

function App() {
    return (
        <QueryClientProvider client={queryClient}>
            <BrowserRouter>
                <div className="min-h-screen bg-gray-50">
                    <Routes>
                        <Route path="/" element={<AdminLogin />} />

                        {/* Protected Routes */}
                        <Route element={<PrivateRoute allowedRole="ADMIN" />}>
                            <Route path="/admin/dashboard" element={<AdminDashboard />} />
                            <Route path="/admin/customer-management/icoin" element={<ICoinManagement />} />
                            
                            {/* Question Bank Routes */}
                            <Route path="/admin/questions/vocabulary" element={<CategoryPage skill="VOCABULARY" title="Vocabulary" />} />
                            <Route path="/admin/questions/listening" element={<CategoryPage skill="LISTENING" title="Listening" />} />
                            <Route path="/admin/questions/reading" element={<CategoryPage skill="READING" title="Reading" />} />
                            <Route path="/admin/questions/writing" element={<CategoryPage skill="WRITING" title="Writing" />} />
                            <Route path="/admin/questions/exam" element={<ExamList />} />
                        </Route>

                        {/* Public Test Route */}
                        <Route path="/admin/quiz-bank-test" element={<QuizBankTestPage />} />

                        <Route path="*" element={<Navigate to="/" replace />} />
                    </Routes>
                </div>
            </BrowserRouter>
        </QueryClientProvider>
    );
}

export default App;
