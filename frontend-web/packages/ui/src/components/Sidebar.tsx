import React, { useState } from "react";
import { Link, useLocation } from "react-router-dom";
import { ChevronDown, ChevronRight, Menu, X } from "lucide-react";

export interface NavItem {
    title: string;
    href?: string;
    icon?: React.ReactNode;
    isNew?: boolean;
    children?: NavItem[];
}

export interface SidebarProps {
    items: NavItem[];
    appName?: string;
}

export function Sidebar({ items, appName = "EnglishHub" }: SidebarProps) {
    const [isOpen, setIsOpen] = useState(true);
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
            {/* Mobile Toggle */}
            <button
                className="md:hidden fixed top-4 right-4 z-50 p-2 bg-white rounded-md shadow-md"
                onClick={() => setIsOpen(!isOpen)}
            >
                {isOpen ? <X size={20} /> : <Menu size={20} />}
            </button>

            {/* Sidebar Content */}
            <aside
                className={`fixed md:sticky top-0 left-0 z-40 h-screen w-64 bg-white border-r border-gray-100 shadow-sm transition-transform duration-300 ease-in-out ${isOpen ? "translate-x-0" : "-translate-x-full md:translate-x-0"
                    } flex flex-col`}
            >
                {/* Logo Area */}
                <div className="flex items-center gap-3 px-6 py-8 border-b border-gray-50">
                    <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center text-primary border border-primary/20">
                        {/* Simple planet/orbit icon substitute */}
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="w-5 h-5">
                            <circle cx="12" cy="12" r="8" />
                            <path d="M12 2v20M2 12h20" className="opacity-30" />
                            <path d="M4.93 4.93l14.14 14.14M4.93 19.07L19.07 4.93" className="opacity-30" />
                            <ellipse cx="12" cy="12" rx="10" ry="4" transform="rotate(45 12 12)" />
                        </svg>
                    </div>
                    <span className="text-xl font-bold text-gray-800 tracking-tight">{appName}</span>
                </div>

                {/* Navigation */}
                <nav className="flex-1 overflow-y-auto py-6 px-4 space-y-1 custom-scrollbar">
                    {items.map((item, idx) => {
                        const hasChildren = item.children && item.children.length > 0;
                        const active = isRouteActive(item.href) || isGroupActive(item.children);

                        return (
                            <div key={idx} className="mb-2">
                                {/* Parent Item */}
                                <div
                                    className={`group flex items-center justify-between px-3 py-2.5 rounded-xl cursor-pointer transition-colors ${active
                                            ? "bg-primary text-white shadow-md shadow-primary/20"
                                            : "text-sidebar-inactive hover:bg-gray-50 hover:text-gray-900"
                                        }`}
                                    onClick={() => {
                                        if (hasChildren) {
                                            toggleExpand(item.title);
                                        }
                                    }}
                                >
                                    <div className="flex items-center gap-3">
                                        <span className={`${active ? "text-white" : "text-gray-400 group-hover:text-primary"} transition-colors`}>
                                            {item.icon}
                                        </span>
                                        {hasChildren ? (
                                            <span className="text-sm font-medium">{item.title}</span>
                                        ) : (
                                            <Link to={item.href || "#"} className="text-sm font-medium w-full block">
                                                {item.title}
                                            </Link>
                                        )}
                                    </div>

                                    <div className="flex items-center gap-2">
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
                                </div>

                                {/* Children Items */}
                                {hasChildren && (expandedKeys[item.title] || active) && (
                                    <div className="mt-1 flex flex-col relative before:absolute before:left-[21px] before:top-0 before:bottom-0 before:w-[1px] before:bg-gray-100">
                                        {item.children!.map((child, cIdx) => {
                                            const childActive = isRouteActive(child.href);
                                            return (
                                                <Link
                                                    key={cIdx}
                                                    to={child.href || "#"}
                                                    className={`flex items-center gap-3 pl-11 pr-3 py-2 text-sm rounded-lg transition-colors relative ${childActive
                                                            ? "text-gray-900 font-medium"
                                                            : "text-sidebar-inactive hover:text-gray-900 bg-transparent"
                                                        }`}
                                                >
                                                    {/* Active indicator dot */}
                                                    <div className={`absolute left-[19px] w-[5px] h-[5px] rounded-full transition-all ${childActive ? "bg-primary scale-100" : "bg-transparent scale-0"}`} />
                                                    {child.title}
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
