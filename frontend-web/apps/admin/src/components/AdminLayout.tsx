import React from "react";
import { useNavigate } from "react-router-dom";
import { DashboardLayout, NavItem } from "@english-learning/ui";
import { Home, Database, Users, Settings, Briefcase } from "lucide-react";

interface AdminLayoutProps {
    children: React.ReactNode;
}

import { toast } from "@english-learning/ui";

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
                    navigate("/");
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
                { title: "iCoin Transactions", href: "/admin/customer-management/icoin" },
            ],
        },
        { title: "App Management", href: "/admin/settings", icon: <Settings size={20} /> },
    ];

    return (
        <DashboardLayout 
            sidebarItems={sidebarItems} 
            userName="Admin User" 
            userRole="System Admin"
            onLogout={handleLogout}
        >
            {children}
        </DashboardLayout>
    );
}
