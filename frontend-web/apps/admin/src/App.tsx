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
import { CustomerDetailPage } from "./pages/customers/CustomerDetailPage";
import { TeacherList } from "./pages/teachers/TeacherList";
import { TeacherDetailPage } from "./pages/teachers/TeacherDetailPage";
import TransactionPage from "./pages/ICoinManagement";
import SettingsPage from "./pages/UnderConstruction";
import AppManagementPage from "./pages/appconfig/AppManagementPage";
import FAQManagementPage from "./pages/appconfig/FAQManagementPage";
import LegalManagementPage from "./pages/appconfig/LegalManagementPage";
import { ModerationDashboard } from "./pages/moderation/ModerationDashboard";
import ChatWithTeachers from "./pages/communication/ChatWithTeachers";
import ProfilePage from "./pages/Profile";
import { PrivateRoute, Toaster } from "@english-learning/ui";
import { useAutoLogout } from "@english-learning/api";

export const App: React.FC = () => {
  const token = localStorage.getItem("admin_token");
  useAutoLogout(token);

  return (
    <Router>
        <Toaster position="top-right" richColors closeButton />
        <Routes>
          {}
          <Route path="/login" element={<LoginPage />} />

          {}
          <Route element={<PrivateRoute allowedRole="ADMIN" />}>
            <Route path="/admin" element={<DashboardPage />} />
            <Route path="/admin/profile" element={<ProfilePage />} />
            
            {}
            <Route path="/admin/moderation" element={<ModerationDashboard />} />
            
            {}
            <Route path="/admin/questions/reading" element={<CategoryPage skill="READING" title="Reading" />} />
            <Route path="/admin/questions/listening" element={<CategoryPage skill="LISTENING" title="Listening" />} />
            <Route path="/admin/questions/vocabulary" element={<CategoryPage skill="VOCABULARY" title="Vocabulary" />} />
            <Route path="/admin/questions/writing" element={<CategoryPage skill="WRITING" title="Writing" />} />
            <Route path="/admin/questions/exam" element={<ExamPage />} />
            
            {}
            <Route path="/admin/questions/:id" element={<QuestionDetailView />} />
            <Route path="/admin/questions/:id/edit" element={<QuestionEditPage />} />
            
            {}
            <Route path="/admin/comprehensions/:id" element={<ComprehensionDetailView />} />
            <Route path="/admin/comprehensions/:id/edit" element={<ComprehensionEditPage />} />

            {}
            <Route path="/admin/exams" element={<ExamPage />} />
            <Route path="/admin/exams/:id" element={<SettingsPage title="Exam Detail View" />} /> {}

            {}
            <Route path="/admin/vocabulary" element={<VocabularyPage />} />
            <Route path="/admin/vocabulary/new" element={<VocabularyCreateView />} />
            <Route path="/admin/vocabulary/:id" element={<VocabularyDetailView />} />

            {}
            <Route path="/admin/teachers/list" element={<TeacherList />} />
            <Route path="/admin/teachers/:id" element={<TeacherDetailPage />} />

            {}
            <Route path="/admin/communication/chat" element={<ChatWithTeachers />} />

            {}
            <Route path="/admin/customers/list" element={<UserManagementPage />} />
            <Route path="/admin/customers/:id" element={<CustomerDetailPage />} />
            <Route path="/admin/users" element={<UserManagementPage />} />

            {}
            <Route path="/admin/transactions" element={<TransactionPage />} />

            {}
            <Route path="/admin/settings" element={<AppManagementPage />} />
            <Route path="/admin/faq" element={<FAQManagementPage />} />
            <Route path="/admin/legal" element={<LegalManagementPage />} />
          </Route>

          {}
          <Route path="/" element={<Navigate to="/admin" replace />} />
          <Route path="*" element={<Navigate to="/admin" replace />} />
        </Routes>
    </Router>
  );
};

export default App;
