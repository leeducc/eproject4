import React, { useCallback, useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { DashboardLayout, NavItem, useTheme } from "@english-learning/ui";
import { Layout, Users, MessageSquare, Database, Wallet } from "lucide-react";
import { useAutoLogout } from "@english-learning/api";
import { toast } from "@english-learning/ui";
import { NotificationBell } from "./NotificationBell";
import { useChatNotificationStore } from "../features/chat/notificationStore";

interface TeacherLayoutProps {
    children: React.ReactNode;
}

interface UserProfile {
    userId: number;
    fullName: string;
    role: string;
    avatarUrl?: string;
}

export function TeacherLayout({ children }: TeacherLayoutProps) {
    const navigate = useNavigate();
    const teacherToken = localStorage.getItem("teacher_token");
    useAutoLogout(teacherToken);
    
    const [profile, setProfile] = useState<UserProfile | null>(null);
    const { unreadCounts, fetchUnreadStatus } = useChatNotificationStore();

    useEffect(() => {
        const fetchProfile = async () => {
            try {
                const response = await fetch('http://localhost:8123/api/profile', {
                    headers: { 'Authorization': `Bearer ${localStorage.getItem('teacher_token')}` }
                });
                if (response.ok) {
                    const data = await response.json();
                    setProfile(data);
                }
            } catch (err) {
                console.error('Failed to fetch profile', err);
            }
        };
        fetchProfile();
        fetchUnreadStatus();
    }, [fetchUnreadStatus]);

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
        { title: "My Wallet", href: "/teacher/wallet", icon: <Wallet size={20} /> },
        {
            title: "Teaching Zone",
            icon: <Users size={20} />,
            children: [
                { title: "Grading Queue", href: "/teacher/grading-queue" },
                { title: "Student List", href: "/teacher/coaching/students" },
                { title: "Teaching Schedule", href: "/teacher/schedule" },
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
            ],
        },
        { 
            title: "Communication", 
            icon: <MessageSquare size={20} />,
            badge: Object.values(unreadCounts).reduce((a: any, b: any) => a + (b as number), 0) as number,
            children: [
                { 
                    title: "Chat with Admin", 
                    href: "/teacher/communication/chat",
                    badge: Object.values(unreadCounts).reduce((a: any, b: any) => a + (b as number), 0) as number
                },
            ],
        },
    ];

    const { theme, setTheme } = useTheme();

    const handleToggle = useCallback(() => {
        setTheme(theme === "dark" ? "light" : "dark");
    }, [theme, setTheme]);

    return (
        <DashboardLayout 
            sidebarItems={sidebarItems} 
            userName={profile?.fullName || "Teacher User"} 
            userRole={profile?.role || "ESL Instructor"}
            onLogout={handleLogout}
            theme={theme}
            toggleTheme={handleToggle}
            notificationBell={profile && <NotificationBell token={localStorage.getItem('teacher_token')!} profile={{ userId: profile.userId }} />}
            profileImageUrl={profile?.avatarUrl}
            onProfileClick={() => {
                console.log("[TeacherLayout] Navigating to profile...");
                navigate("/teacher/profile");
            }}
        >
            {children}
        </DashboardLayout>
    );
}
