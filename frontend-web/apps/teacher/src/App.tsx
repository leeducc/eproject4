import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { PrivateRoute } from "@english-learning/ui";
import TeacherLogin from "./pages/Login";

const queryClient = new QueryClient();

import TeacherDashboard from "./pages/Dashboard";

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
                        </Route>

                        <Route path="*" element={<Navigate to="/" replace />} />
                    </Routes>
                </div>
            </BrowserRouter>
        </QueryClientProvider>
    );
}

export default App;
