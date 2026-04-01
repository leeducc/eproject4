import React, { useCallback } from "react";
import { useNavigate } from "react-router-dom";
import { DashboardLayout, NavItem, toast } from "@english-learning/ui";
import { Home, Database, Users, Settings, Briefcase, AlertCircle } from "lucide-react";

interface AdminLayoutProps {
    children: React.ReactNode;
}

import { useThemeStore } from "../store/useThemeStore";

export function AdminLayout({ children }: AdminLayoutProps) {
    const navigate = useNavigate();

    const handleLogout = () => {
        toast("Ready to leave?", {
            description: "Are you sure you want to log out from the admin panel?",
            action: {
                label: "Logout",
                onClick: () => {
                    console.log("[AdminLayout] User confirmed logout. Clearing session...");
                    localStorage.removeItem("admin_token");
                    toast.success("Logged out successfully");
                    navigate("/login");
                },
            },
            cancel: {
                label: "Cancel",
                onClick: () => console.log("[AdminLayout] Logout cancelled"),
            },
        });
    };

    const sidebarItems: NavItem[] = [
        { title: "Dashboard Overview", href: "/admin/dashboard", icon: <Home size={20} /> },
        { 
            title: "Moderation", 
            href: "/admin/moderation", 
            icon: <AlertCircle size={20} />,
            isNew: true 
        },
        {
            title: "Questions Bank",
            icon: <Database size={20} />,
            isNew: true,
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
                { title: "iCoin Transactions", href: "/admin/customers/icoin" },
            ],
        },
        { 
            title: "App Management", 
            icon: <Settings size={20} />,
            children: [
                { title: "Sections Configuration", href: "/admin/settings" },
                { title: "FAQ Management", href: "/admin/faq" },
                { title: "Legal & Policies", href: "/admin/legal" },
            ],
        },
    ];

    const theme = useThemeStore((state) => state.theme);
    const toggleTheme = useThemeStore((state) => state.toggleTheme);

    const handleToggle = useCallback(() => {
        toggleTheme();
    }, [toggleTheme]);

    return (
        <DashboardLayout 
            sidebarItems={sidebarItems} 
            userName="Admin User" 
            userRole="System Admin"
            onLogout={handleLogout}
            theme={theme}
            toggleTheme={handleToggle}
        >
            {children}
        </DashboardLayout>
    );
}
