import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { PrivateRoute } from "@english-learning/ui";
import AdminLogin from "./pages/Login";

const queryClient = new QueryClient();

import AdminDashboard from "./pages/Dashboard";
import ICoinManagement from "./pages/ICoinManagement";

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
                        </Route>

                        <Route path="*" element={<Navigate to="/" replace />} />
                    </Routes>
                </div>
            </BrowserRouter>
        </QueryClientProvider>
    );
}

export default App;
