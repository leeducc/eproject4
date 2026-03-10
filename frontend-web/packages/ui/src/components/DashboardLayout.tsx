import React from "react";
import { Sidebar, NavItem } from "./Sidebar";
import { Bell, Mail, Target, Settings, Search, Sun, Moon } from "lucide-react";

export interface DashboardLayoutProps {
    children: React.ReactNode;
    sidebarItems: NavItem[];
    userName?: string;
    userRole?: string;
}

export function DashboardLayout({ children, sidebarItems, userName = "Patricia Peters", userRole = "Online" }: DashboardLayoutProps) {
    return (
        <div className="flex h-screen bg-dashboard-bg overflow-hidden font-sans">
            <Sidebar items={sidebarItems} appName="EnglishHub" />

            <div className="flex-1 flex flex-col overflow-hidden">
                {/* Top Header */}
                <header className="h-20 bg-white/50 backdrop-blur-md border-b border-gray-100 flex items-center justify-between px-8 shrink-0">
                    <div className="flex items-center bg-white border border-gray-100 rounded-full px-4 py-2 w-96 shadow-sm">
                        <Search className="w-4 h-4 text-gray-400 mr-2" />
                        <input
                            type="text"
                            placeholder="Search here..."
                            className="bg-transparent border-none outline-none text-sm w-full placeholder:text-gray-400 text-gray-700"
                        />
                    </div>

                    <div className="flex items-center gap-6">
                        <div className="flex items-center gap-3 border-r border-gray-100 pr-6">
                            <Sun className="w-5 h-5 text-gray-400 cursor-pointer hover:text-gray-600 transition-colors" />
                            <div className="w-10 h-5 bg-primary rounded-full relative cursor-pointer flex items-center">
                                <div className="w-3.5 h-3.5 bg-white rounded-full absolute left-1"></div>
                            </div>
                            <Moon className="w-5 h-5 text-gray-400 cursor-pointer hover:text-gray-600 transition-colors" />
                        </div>

                        <div className="flex items-center gap-4 border-r border-gray-100 pr-6">
                            <Target className="w-5 h-5 text-gray-400 cursor-pointer hover:text-gray-600" />
                            <div className="relative">
                                <Bell className="w-5 h-5 text-gray-400 cursor-pointer hover:text-gray-600" />
                                <span className="absolute -top-1.5 -right-1.5 w-4 h-4 bg-primary text-white text-[10px] items-center justify-center flex font-bold rounded-full border-2 border-white">1</span>
                            </div>
                            <Mail className="w-5 h-5 text-gray-400 cursor-pointer hover:text-gray-600" />
                        </div>

                        <div className="flex items-center gap-3">
                            <div className="flex flex-col items-end">
                                <span className="text-sm font-bold text-gray-800">{userName}</span>
                                <div className="flex items-center gap-1.5">
                                    <span className="w-2 h-2 bg-secondary rounded-full"></span>
                                    <span className="text-xs text-sidebar-inactive">{userRole}</span>
                                </div>
                            </div>
                            <div className="w-10 h-10 rounded-full bg-orange-100 border-2 border-white shadow-sm overflow-hidden flex items-center justify-center">
                                {/* Avatar Placeholder */}
                                <span className="text-lg">🧑‍🏫</span>
                            </div>
                            <Settings className="w-5 h-5 text-gray-400 ml-2 cursor-pointer hover:text-gray-600" />
                        </div>
                    </div>
                </header>

                {/* Main Content Area */}
                <main className="flex-1 overflow-x-hidden overflow-y-auto bg-dashboard-bg p-8">
                    {children}
                </main>
            </div>
        </div>
    );
}

export function StatCard({ title, value, percentage, isPositive, bgColorClass, icon }: any) {
    return (
        <div className={`${bgColorClass} rounded-2xl p-6 relative overflow-hidden text-white shadow-lg`}>
            <div className="absolute -right-4 -top-4 w-24 h-24 bg-white/10 rounded-full blur-xl"></div>
            <div className="absolute -left-4 -bottom-4 w-16 h-16 bg-white/10 rounded-full blur-lg"></div>

            <div className="flex justify-between items-start relative z-10">
                <div className="w-10 h-10 rounded-xl bg-white/20 flex items-center justify-center backdrop-blur-sm">
                    {icon}
                </div>
                <div className="bg-white/20 px-2.5 py-1 rounded-full text-xs font-semibold backdrop-blur-sm flex items-center gap-1">
                    {isPositive ? "↗" : "↘"} {percentage}%
                </div>
            </div>

            <div className="mt-4 relative z-10">
                <h3 className="text-3xl font-bold tracking-tight">{value}</h3>
                <p className="text-white/80 text-sm mt-1">{title}</p>
            </div>
        </div>
    );
}
