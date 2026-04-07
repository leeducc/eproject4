import React, { useState } from "react";
import { Link, useLocation } from "react-router-dom";
import { ChevronDown, ChevronRight, Menu, X, ChevronLeft } from "lucide-react";

export interface NavItem {
    title: string;
    href?: string;
    icon?: React.ReactNode;
    isNew?: boolean;
    badge?: number;
    children?: NavItem[];
}

export interface SidebarProps {
    items: NavItem[];
    appName?: string;
    isCollapsed?: boolean;
    onToggleCollapse?: () => void;
}

export function Sidebar({ items, appName = "EnglishHub", isCollapsed = false, onToggleCollapse }: SidebarProps) {
    const [isMobileOpen, setIsMobileOpen] = useState(false);
    const [expandedKeys, setExpandedKeys] = useState<Record<string, boolean>>({});
    const location = useLocation();

    const toggleExpand = (title: string) => {
        setExpandedKeys((prev) => ({ ...prev, [title]: !prev[title] }));
    };

    const isRouteActive = (href?: string) => {
        if (!href) return false;
        return location.pathname.startsWith(href);
    };

    const isGroupActive = (children?: NavItem[]) => {
        if (!children) return false;
        return children.some((child) => isRouteActive(child.href));
    };

    return (
        <>
            {}
            <button
                className="md:hidden fixed top-4 right-4 z-50 p-2 bg-white dark:bg-slate-800 rounded-md shadow-md border dark:border-slate-700"
                onClick={() => setIsMobileOpen(!isMobileOpen)}
            >
                {isMobileOpen ? <X size={20} className="dark:text-slate-100" /> : <Menu size={20} className="dark:text-slate-100" />}
            </button>

            {}
            <aside
                className={`fixed md:sticky top-0 left-0 z-40 h-screen bg-white dark:bg-slate-900 border-r border-gray-100 dark:border-slate-800 shadow-sm transition-all duration-300 ease-in-out ${
                    isMobileOpen ? "translate-x-0" : "-translate-x-full md:translate-x-0"
                } ${isCollapsed ? "w-20" : "w-64"} flex flex-col`}
            >
                {}
                <div className={`flex items-center justify-between h-20 px-6 border-b border-gray-50 dark:border-slate-800 shrink-0`}>
                    <div className="flex items-center gap-3 overflow-hidden">
                        <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center text-primary border border-primary/20 shrink-0">
                            {}
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="w-5 h-5">
                                <circle cx="12" cy="12" r="8" />
                                <path d="M12 2v20M2 12h20" className="opacity-30" />
                                <path d="M4.93 4.93l14.14 14.14M4.93 19.07L19.07 4.93" className="opacity-30" />
                                <ellipse cx="12" cy="12" rx="10" ry="4" transform="rotate(45 12 12)" />
                            </svg>
                        </div>
                        {!isCollapsed && (
                            <span className="text-xl font-bold text-gray-800 dark:text-slate-100 tracking-tight whitespace-nowrap animate-in fade-in duration-300">
                                {appName}
                            </span>
                        )}
                    </div>
                    
                    {}
                    <button 
                        onClick={onToggleCollapse}
                        className="hidden md:flex items-center justify-center w-8 h-8 rounded-lg text-gray-400 hover:text-primary hover:bg-primary/5 transition-colors ml-auto"
                    >
                        {isCollapsed ? <Menu size={18} /> : <ChevronLeft size={20} />}
                    </button>
                </div>

                {}
                <nav className="flex-1 overflow-y-auto py-6 px-4 space-y-1 custom-scrollbar overflow-x-hidden">
                    {items.map((item, idx) => {
                        const hasChildren = item.children && item.children.length > 0;
                        const active = isRouteActive(item.href) || isGroupActive(item.children);

                        return (
                            <div key={idx} className="mb-2">
                                {}
                                <div
                                    className={`group flex items-center justify-between px-3 py-2.5 rounded-xl cursor-pointer transition-all ${active
                                            ? "bg-primary text-white shadow-md shadow-primary/20"
                                            : "text-sidebar-inactive dark:text-slate-400 hover:bg-gray-50 dark:hover:bg-slate-800 hover:text-gray-900 dark:hover:text-slate-100"
                                        } ${isCollapsed ? "justify-center px-0" : ""}`}
                                    onClick={() => {
                                        if (hasChildren && !isCollapsed) {
                                            toggleExpand(item.title);
                                        }
                                    }}
                                    title={isCollapsed ? item.title : ""}
                                >
                                    <div className={`flex items-center ${isCollapsed ? "justify-center w-full" : "gap-3"}`}>
                                        <span className={`${active ? "text-white" : "text-gray-400 group-hover:text-primary"} transition-colors shrink-0`}>
                                            {item.icon}
                                        </span>
                                        {!isCollapsed && (
                                            hasChildren ? (
                                                <span className="text-sm font-medium whitespace-nowrap">{item.title}</span>
                                            ) : (
                                                <Link to={item.href || "#"} className="text-sm font-medium w-full block whitespace-nowrap">
                                                    {item.title}
                                                </Link>
                                            )
                                        )}
                                    </div>

                                    {!isCollapsed && (
                                        <div className="flex items-center gap-2">
                                            {item.badge && item.badge > 0 && (
                                                <span className={`flex h-5 min-w-[20px] px-1 items-center justify-center rounded-full text-[10px] font-black ${active ? "bg-white text-primary" : "bg-primary text-white"} shadow-sm transition-all`}>
                                                    {item.badge}
                                                </span>
                                            )}
                                            {item.isNew && (
                                                <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${active ? "bg-white/20 text-white" : "bg-primary/10 text-primary"}`}>
                                                    NEW
                                                </span>
                                            )}
                                            {hasChildren && (
                                                <span className="opacity-80">
                                                    {expandedKeys[item.title] || active ? <ChevronDown size={16} /> : <ChevronRight size={16} />}
                                                </span>
                                            )}
                                        </div>
                                    )}
                                </div>

                                {}
                                {!isCollapsed && hasChildren && (expandedKeys[item.title] || active) && (
                                    <div className="mt-1 flex flex-col relative before:absolute before:left-[21px] before:top-0 before:bottom-0 before:w-[1px] before:bg-gray-100 dark:before:bg-slate-800 animate-in slide-in-from-top-2 duration-200">
                                        {item.children!.map((child, cIdx) => {
                                            const childActive = isRouteActive(child.href);
                                            return (
                                                <Link
                                                    key={cIdx}
                                                    to={child.href || "#"}
                                                    className={`flex items-center gap-3 pl-11 pr-3 py-2 text-sm rounded-lg transition-colors relative ${childActive
                                                            ? "text-gray-900 dark:text-slate-100 font-medium"
                                                            : "text-sidebar-inactive dark:text-slate-400 hover:text-gray-900 dark:hover:text-slate-100 bg-transparent"
                                                        }`}
                                                >
                                                    {}
                                                    <div className={`absolute left-[19px] w-[5px] h-[5px] rounded-full transition-all ${childActive ? "bg-primary scale-100" : "bg-transparent scale-0"}`} />
                                                    <span className="flex-1 truncate">{child.title}</span>
                                                    {child.badge && child.badge > 0 && (
                                                        <span className="flex h-4 min-w-[16px] px-1 items-center justify-center rounded-full bg-primary text-white text-[9px] font-black shadow-sm">
                                                            {child.badge}
                                                        </span>
                                                    )}
                                                </Link>
                                            );
                                        })}
                                    </div>
                                )}
                            </div>
                        );
                    })}
                </nav>
            </aside>
        </>
    );
}
