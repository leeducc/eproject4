import { DashboardLayout, NavItem } from "@english-learning/ui";
import { Layout, Users, Calendar, Database, Eye, PlusCircle, MessageSquare } from "lucide-react";

export default function TeacherDashboard() {
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
                { title: "View Questions", href: "/teacher/questions/view", icon: <Eye size={16} /> },
                { title: "Submit New Question", href: "/teacher/questions/submit", icon: <PlusCircle size={16} /> },
            ],
        },
        { title: "Communication", href: "/teacher/messages", icon: <MessageSquare size={20} /> },
    ];

    return (
        <DashboardLayout sidebarItems={sidebarItems} userName="Teacher User" userRole="ESL Instructor">
            <div className="bg-white rounded-2xl p-8 border border-gray-100 shadow-sm mb-6">
                <h2 className="text-2xl font-bold text-gray-800 mb-2">Welcome back, Teacher!</h2>
                <p className="text-gray-500">Here's your schedule and recent updates for today.</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="md:col-span-2 bg-white rounded-2xl p-6 border border-gray-100 shadow-sm min-h-[400px]">
                    <h3 className="font-semibold text-gray-800 border-b border-gray-100 pb-4 mb-4">Upcoming 1-on-1 Sessions</h3>
                    <div className="flex flex-col items-center justify-center text-gray-400 h-64">
                        <Calendar size={48} className="mb-4 text-gray-200" />
                        <p>No upcoming sessions today.</p>
                    </div>
                </div>
                <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
                    <h3 className="font-semibold text-gray-800 border-b border-gray-100 pb-4 mb-4">Recent Question Submissions</h3>
                    <div className="space-y-4">
                        {/* Mock items */}
                        <div className="flex gap-3">
                            <div className="w-8 h-8 rounded bg-primary/10 flex items-center justify-center text-primary shrink-0"><Database size={14} /></div>
                            <div>
                                <h4 className="text-sm font-medium text-gray-800">Advanced Vocabulary Q42</h4>
                                <p className="text-xs text-secondary mt-1 flex items-center gap-1">
                                    <span className="w-1.5 h-1.5 bg-secondary rounded-full"></span> Approved
                                </p>
                            </div>
                        </div>
                        <div className="flex gap-3">
                            <div className="w-8 h-8 rounded bg-primary/10 flex items-center justify-center text-primary shrink-0"><Database size={14} /></div>
                            <div>
                                <h4 className="text-sm font-medium text-gray-800">Basic Grammar Q12</h4>
                                <p className="text-xs text-amber-500 mt-1 flex items-center gap-1">
                                    <span className="w-1.5 h-1.5 bg-amber-500 rounded-full"></span> Pending Review
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </DashboardLayout>
    );
}
