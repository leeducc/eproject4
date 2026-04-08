import React, { useCallback, useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { DashboardLayout, NavItem, toast, useTheme } from "@english-learning/ui";
import { Home, Database, Users, Settings, Briefcase, MessageSquare } from "lucide-react";
import { useAutoLogout } from "@english-learning/api";
import { NotificationBell } from "./NotificationBell";
import { useChatNotificationStore } from "../features/chat/notificationStore";

interface AdminLayoutProps {
    children: React.ReactNode;
    title?: string;
}

interface UserProfile {
    userId: number;
    fullName: string;
    role: string;
    avatarUrl?: string;
}

export function AdminLayout({ children, title }: AdminLayoutProps) {
    if (title) {
        console.log(`[AdminLayout] Rendering page: ${title}`);
    }
    const navigate = useNavigate();
    const adminToken = localStorage.getItem("admin_token");
    useAutoLogout(adminToken);
    
    const [profile, setProfile] = useState<UserProfile | null>(null);
    const { unreadCounts, fetchUnreadStatus } = useChatNotificationStore();

    useEffect(() => {
        const fetchProfile = async () => {
            if (profile) return; 
            try {
                console.log("[AdminLayout] Fetching profile...");
                const response = await fetch('http://localhost:8123/api/profile', {
                    headers: { 'Authorization': `Bearer ${localStorage.getItem('admin_token')}` }
                });
                if (response.ok) {
                    const data = await response.json();
                    console.log("[AdminLayout] Profile fetched successfully:", data.email);
                    setProfile(data);
                }
            } catch (err) {
                console.error('Failed to fetch profile', err);
            }
        };
        fetchProfile();
    }, []); 

    useEffect(() => {
        fetchUnreadStatus();
    }, [fetchUnreadStatus]);

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
        { title: "Dashboard Overview", href: "/admin", icon: <Home size={20} /> },
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
            title: "Communication",
            icon: <MessageSquare size={20} />,
            badge: Object.values(unreadCounts).reduce((a: any, b: any) => a + (b as number), 0) as number,
            children: [
                { 
                    title: "Chat with Teachers", 
                    href: "/admin/communication/chat",
                    badge: Object.values(unreadCounts).reduce((a: any, b: any) => a + (b as number), 0) as number
                },
            ],
        },
        {
            title: "Customer Management",
            icon: <Users size={20} />,
            children: [
                { title: "Customer List", href: "/admin/customers/list" },
                { title: "Messages", href: "/admin/customers/messages" },
                { title: "Reports", href: "/admin/moderation" },
                { title: "Requests", href: "/admin/customers/requests" },
                { title: "Feedback Requests", href: "/admin/customers/feedback" },
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

    const { theme, setTheme } = useTheme();

    const handleToggle = useCallback(() => {
        setTheme(theme === "dark" ? "light" : "dark");
    }, [theme, setTheme]);

    return (
        <DashboardLayout 
            sidebarItems={sidebarItems} 
            userName={profile?.fullName || "Admin User"} 
            userRole={profile?.role || "System Admin"}
            onLogout={handleLogout}
            theme={theme}
            toggleTheme={handleToggle}
            notificationBell={profile && <NotificationBell token={localStorage.getItem('admin_token')!} profile={{ userId: profile.userId }} />}
            profileImageUrl={profile?.avatarUrl}
            onProfileClick={() => {
                console.log("[AdminLayout] Navigating to profile...");
                navigate("/admin/profile");
            }}
        >
            {children}
        </DashboardLayout>
    );
}
