import React from "react";
import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";
import LoginPage from "./pages/Login";
import DashboardPage from "./pages/Dashboard";
import { CategoryPage } from "./pages/questions/CategoryPage";
import { QuestionDetailView } from "./pages/questions/QuestionDetailView";
import { QuestionEditPage } from "./pages/questions/QuestionEditPage";
import { ComprehensionDetailView } from "./pages/questions/ComprehensionDetailView";
import { ComprehensionEditPage } from "./pages/questions/ComprehensionEditPage";
import { ExamList as ExamPage } from "./pages/questions/ExamList";
import { VocabularyPage } from "./pages/vocabulary/VocabularyPage";
import { VocabularyDetailView } from "./pages/vocabulary/VocabularyDetailView";
import { VocabularyCreateView } from "./pages/vocabulary/VocabularyCreateView";
import { CustomerList as UserManagementPage } from "./pages/customers/CustomerList";
import TransactionPage from "./pages/ICoinManagement";
import SettingsPage from "./pages/UnderConstruction";
import { PrivateRoute, Toaster } from "@english-learning/ui";

export const App: React.FC = () => {
  return (
    <Router>
        <Toaster position="top-right" richColors closeButton />
        <Routes>
          {/* Public Routes */}
          <Route path="/login" element={<LoginPage />} />

          {/* Protected Admin Routes */}
          <Route element={<PrivateRoute allowedRole="ADMIN" />}>
            <Route path="/admin" element={<DashboardPage />} />
            
            {/* Question Bank Routes */}
            <Route path="/admin/questions/reading" element={<CategoryPage skill="READING" title="Reading" />} />
            <Route path="/admin/questions/listening" element={<CategoryPage skill="LISTENING" title="Listening" />} />
            <Route path="/admin/questions/vocabulary" element={<CategoryPage skill="VOCABULARY" title="Vocabulary" />} />
            <Route path="/admin/questions/writing" element={<CategoryPage skill="WRITING" title="Writing" />} />
            <Route path="/admin/questions/exam" element={<ExamPage />} />
            
            {/* Dedicated Question View/Edit */}
            <Route path="/admin/questions/:id" element={<QuestionDetailView />} />
            <Route path="/admin/questions/:id/edit" element={<QuestionEditPage />} />
            
            {/* Dedicated Comprehension View/Edit */}
            <Route path="/admin/comprehensions/:id" element={<ComprehensionDetailView />} />
            <Route path="/admin/comprehensions/:id/edit" element={<ComprehensionEditPage />} />

            {/* Exam Routes */}
            <Route path="/admin/exams" element={<ExamPage />} />
            <Route path="/admin/exams/:id" element={<SettingsPage title="Exam Detail View" />} /> {/* Placeholder */}

            {/* Vocabulary Routes */}
            <Route path="/admin/vocabulary" element={<VocabularyPage />} />
            <Route path="/admin/vocabulary/new" element={<VocabularyCreateView />} />
            <Route path="/admin/vocabulary/:id" element={<VocabularyDetailView />} />

            {/* User Management */}
            <Route path="/admin/users" element={<UserManagementPage />} />

            {/* Finance/Transactions */}
            <Route path="/admin/transactions" element={<TransactionPage />} />

            {/* Settings */}
            <Route path="/admin/settings" element={<SettingsPage title="Settings" />} />
          </Route>

          {/* Default Redirect */}
          <Route path="/" element={<Navigate to="/admin" replace />} />
          <Route path="*" element={<Navigate to="/admin" replace />} />
        </Routes>
    </Router>
  );
};

export default App;
