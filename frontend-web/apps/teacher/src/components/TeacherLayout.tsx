import React from "react";
import { useNavigate } from "react-router-dom";
import { DashboardLayout, NavItem } from "@english-learning/ui";
import { Layout, Users, MessageSquare, Database } from "lucide-react";

interface TeacherLayoutProps {
    children: React.ReactNode;
}

import { toast } from "@english-learning/ui";

export function TeacherLayout({ children }: TeacherLayoutProps) {
    const navigate = useNavigate();

    const handleLogout = () => {
        toast("Ready to leave?", {
            description: "Are you sure you want to log out from the teacher panel?",
            action: {
                label: "Logout",
                onClick: () => {
                    console.log("[TeacherLayout] User confirmed logout. Clearing session...");
                    localStorage.removeItem("teacher_token");
                    toast.success("Logged out successfully");
                    navigate("/");
                },
            },
            cancel: {
                label: "Cancel",
                onClick: () => console.log("[TeacherLayout] Logout cancelled"),
            },
        });
    };

    const sidebarItems: NavItem[] = [
        { title: "My Dashboard", href: "/teacher/dashboard", icon: <Layout size={20} /> },
        {
            title: "1-on-1 Coaching",
            icon: <Users size={20} />,
            children: [
                { title: "Student List", href: "/teacher/coaching/students" },
                { title: "Session Calendar", href: "/teacher/coaching/calendar" },
            ],
        },
        {
            title: "Questions Bank",
            icon: <Database size={20} />,
            children: [
                { title: "Vocabulary", href: "/teacher/questions/vocabulary" },
                { title: "Listening", href: "/teacher/questions/listening" },
                { title: "Reading", href: "/teacher/questions/reading" },
                { title: "Writing", href: "/teacher/questions/writing" },
                { title: "Exam", href: "/teacher/questions/exam" },
                // These were the original links in TeacherDashboard.tsx:
                // { title: "View Questions", href: "/teacher/questions/view", icon: <Eye size={16} /> },
                // { title: "Submit New Question", href: "/teacher/questions/submit", icon: <PlusCircle size={16} /> },
            ],
        },
        { title: "Communication", href: "/teacher/messages", icon: <MessageSquare size={20} /> },
    ];

    return (
        <DashboardLayout 
            sidebarItems={sidebarItems} 
            userName="Teacher User" 
            userRole="ESL Instructor"
            onLogout={handleLogout}
        >
            {children}
        </DashboardLayout>
    );
}
