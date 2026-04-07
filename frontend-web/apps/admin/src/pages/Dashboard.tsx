import { StatCard } from "@english-learning/ui";
import { Users, BookOpen, Edit3, CheckSquare, Settings } from "lucide-react";
import { AdminLayout } from "../components/AdminLayout";

export default function AdminDashboard() {
    return (
        <AdminLayout>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <StatCard
                    title="Total Students"
                    value="1,253"
                    percentage={25}
                    isPositive={true}
                    bgColorClass="bg-primary"
                    icon={<Users size={20} />}
                />
                <StatCard
                    title="Daily Attendance"
                    value="93%"
                    percentage={15}
                    isPositive={true}
                    bgColorClass="bg-secondary"
                    icon={<CheckSquare size={20} />}
                />
                <StatCard
                    title="Absences (Today)"
                    value="145"
                    percentage={5}
                    isPositive={false}
                    bgColorClass="bg-accent"
                    icon={<Edit3 size={20} />}
                />
                <StatCard
                    title="Active Exams"
                    value="65"
                    percentage={5}
                    isPositive={false}
                    bgColorClass="bg-amber-500"
                    icon={<BookOpen size={20} />}
                />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <div className="lg:col-span-2 bg-white dark:bg-slate-900 rounded-2xl p-6 border border-gray-100 dark:border-slate-800 shadow-sm">
                    <div className="flex justify-between items-center mb-6">
                        <h3 className="font-semibold text-gray-800 dark:text-slate-100">Weekly Target</h3>
                        <button className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"><Settings size={16} /></button>
                    </div>
                    <div className="flex items-end gap-10 mb-8">
                        <div>
                            <h2 className="text-4xl font-bold text-gray-800 dark:text-slate-100">38,482</h2>
                            <p className="text-secondary text-sm font-medium mt-1 flex items-center gap-1">↗ 25% <span className="text-gray-400 font-normal dark:text-slate-500">from last month</span></p>
                        </div>
                        <div className="flex-1 flex gap-8 justify-end">
                            <div>
                                <span className="text-primary text-xs font-bold px-2 py-0.5 bg-primary/10 rounded-full mb-1 inline-block">50%</span>
                                <p className="text-gray-800 dark:text-slate-200 font-bold text-xl">19,241</p>
                                <p className="text-gray-400 dark:text-slate-500 text-xs flex items-center gap-1"><span className="w-1.5 h-1.5 bg-primary rounded-full"></span> Completed</p>
                            </div>
                            <div>
                                <span className="text-cyan-500 text-xs font-bold px-2 py-0.5 bg-cyan-100 dark:bg-cyan-900/30 rounded-full mb-1 inline-block">25%</span>
                                <p className="text-gray-800 dark:text-slate-200 font-bold text-xl">8,394</p>
                                <p className="text-gray-400 dark:text-slate-500 text-xs flex items-center gap-1"><span className="w-1.5 h-1.5 bg-cyan-500 rounded-full"></span> In Progress</p>
                            </div>
                            <div>
                                <span className="text-amber-500 text-xs font-bold px-2 py-0.5 bg-amber-100 dark:bg-amber-900/30 rounded-full mb-1 inline-block">6%</span>
                                <p className="text-gray-800 dark:text-slate-200 font-bold text-xl">1,589</p>
                                <p className="text-gray-400 dark:text-slate-500 text-xs flex items-center gap-1"><span className="w-1.5 h-1.5 bg-amber-500 rounded-full"></span> Pending</p>
                            </div>
                        </div>
                    </div>

                    {}
                    <div className="w-full h-8 flex rounded-xl overflow-hidden mb-6">
                        <div className="h-full bg-primary w-1/2 flex items-center justify-center text-white text-xs font-bold">50%</div>
                        <div className="h-full bg-cyan-400 w-1/4 flex items-center justify-center text-white text-xs font-bold">25%</div>
                        <div className="h-full bg-amber-400 w-1/5 flex items-center justify-center text-white text-xs font-bold">6%</div>
                        <div className="h-full bg-gray-100 dark:bg-slate-800 flex-1"></div>
                    </div>
                </div>

                <div className="bg-white dark:bg-slate-900 rounded-2xl p-6 border border-gray-100 dark:border-slate-800 shadow-sm flex flex-col items-center justify-center">
                    <div className="w-full flex justify-between items-center mb-4">
                        <h3 className="font-semibold text-gray-800 dark:text-slate-100">Progress Overview</h3>
                    </div>
                    {}
                    <div className="relative w-48 h-24 overflow-hidden mb-6">
                        <div className="absolute top-0 left-0 w-48 h-48 rounded-full border-[1.5rem] border-gray-100 dark:border-slate-800"></div>
                        <div className="absolute top-0 left-0 w-48 h-48 rounded-full border-[1.5rem] border-primary border-t-transparent border-r-transparent -rotate-45"></div>
                        <div className="absolute top-0 left-0 w-48 h-48 rounded-full border-[1.5rem] border-cyan-400 border-t-transparent border-l-transparent border-b-transparent rotate-[15deg]"></div>
                    </div>
                    <div className="flex w-full justify-between px-4 mt-auto">
                        <div className="text-center">
                            <p className="text-gray-400 shadow-sm-dark:text-slate-500 text-xs flex items-center justify-center gap-1"><span className="w-1.5 h-1.5 bg-primary rounded-full"></span> Completed</p>
                            <p className="text-xl font-bold text-gray-800 dark:text-slate-200 mt-1">32,948</p>
                        </div>
                        <div className="text-center">
                            <p className="text-gray-400 dark:text-slate-500 text-xs flex items-center justify-center gap-1"><span className="w-1.5 h-1.5 bg-cyan-400 rounded-full"></span> In Progress</p>
                            <p className="text-xl font-bold text-gray-800 dark:text-slate-200 mt-1">16,927</p>
                        </div>
                    </div>
                </div>
            </div>
        </AdminLayout>
    );
}
