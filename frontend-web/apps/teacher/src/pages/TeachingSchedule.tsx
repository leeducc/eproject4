import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@english-learning/api";
import { TeacherLayout } from "../components/TeacherLayout";
import { Calendar, Clock, Plus, Trash2, User } from "lucide-react";
import { addDays, format, isBefore, parse, startOfDay } from "date-fns";
import { toast } from "sonner";

interface Slot {
    id: number;
    startTime: string; 
    endTime: string;
    status: "AVAILABLE" | "BOOKED" | "ONGOING" | "COMPLETED" | "CANCELLED";
    studentName?: string;
}

const parseDateString = (dateStr: string): Date | null => {
    if (!dateStr) return null;
    try {
        if (dateStr.includes('/')) {
            return parse(dateStr, "HH:mm dd/MM/yyyy", new Date());
        }
        const d = new Date(dateStr);
        return isNaN(d.getTime()) ? null : d;
    } catch (e) {
        return null;
    }
};

export default function TeachingSchedule() {
    const queryClient = useQueryClient();
    const [date, setDate] = useState(format(new Date(), "yyyy-MM-dd"));
    const [startTime, setStartTime] = useState("08:00");
    const [endTime, setEndTime] = useState("10:00");
    const [duration, setDuration] = useState(30);
    const [viewMode, setViewMode] = useState<"today" | "tomorrow" | "all" | "custom">("all");


    const { data: slots = [], isLoading, isError } = useQuery<Slot[]>({
        queryKey: ["teacher-slots"],
        queryFn: async () => {
            const response = await apiClient.get("/tutoring/slots/teacher/all");
            console.log("[TeachingSchedule] Fetched raw slots:", response.data);
            return response.data;
        }
    });

    const upcomingSlotsCount = slots.filter(s => {
        const sDate = parseDateString(s.startTime);
        return sDate && sDate >= startOfDay(new Date());
    }).length;


    const isDateValidForCreation = !isBefore(parse(date, "yyyy-MM-dd", new Date()), startOfDay(addDays(new Date(), 1)));

    const isOverlapping = slots.some((s: Slot) => {
        const sStart = parseDateString(s.startTime);
        const sEnd = parseDateString(s.endTime);
        
        if (!sStart || !sEnd) return false;

        // Compare using local date strings to ensure we are on the same day
        if (format(sStart, "yyyy-MM-dd") === date) {
            const currentSelectedDate = parse(date, "yyyy-MM-dd", new Date());
            const proposedStart = parse(startTime, "HH:mm", currentSelectedDate);
            const proposedEnd = parse(endTime, "HH:mm", currentSelectedDate);
            
            const overlap = sStart < proposedEnd && proposedStart < sEnd;
            if (overlap) {
                console.warn("[TeachingSchedule] Overlap detected:", {
                    proposed: `${format(proposedStart, "HH:mm")} - ${format(proposedEnd, "HH:mm")}`,
                    existing: `${format(sStart, "HH:mm")} - ${format(sEnd, "HH:mm")}`,
                    slotId: s.id
                });
            }
            return overlap;
        }
        return false;
    });

    console.log("[TeachingSchedule] State:", { date, startTime, endTime, viewMode, slotsCount: slots.length, isOverlapping, isDateValidForCreation });

    const createSlotsMutation = useMutation({
        mutationFn: async () => {
            if (isOverlapping) {
                throw new Error("Không thể đăng ký do trùng lịch dạy.");
            }

            const selectedDate = parse(date, "yyyy-MM-dd", new Date());
            const tomorrow = startOfDay(addDays(new Date(), 1));

            if (isBefore(selectedDate, tomorrow)) {
                throw new Error("Lịch dạy phải được đăng ký trước ít nhất 1 ngày.");
            }

            const startStr = `${startTime} ${format(selectedDate, "dd/MM/yyyy")}`;
            const endStr = `${endTime} ${format(selectedDate, "dd/MM/yyyy")}`;
            
            console.log("[TeachingSchedule] Mutating bulk create:", { startTime: startStr, endTime: endStr, duration });

            return await apiClient.post("/tutoring/slots/teacher/bulk", {
                startTime: startStr,
                endTime: endStr,
                durationMinutes: duration
            });
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ["teacher-slots"] });
            toast.success("Đã mở các slot dạy mới thành công!");
            // Auto switch to custom view for the date just created so user sees them
            setViewMode("custom");
            // Optional: reset times to prevent immediate overlap error confusion
            setStartTime("08:00");
            setEndTime("10:00");
        },
        onError: (err: any) => {
            console.error("[TeachingSchedule] Create error:", err);
            toast.error(err.message || err.response?.data?.message || "Lỗi khi mở slot");
        }
    });

    const deleteSlotMutation = useMutation({
        mutationFn: async (id: number) => {
            return await apiClient.delete(`/tutoring/slots/teacher/${id}`);
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ["teacher-slots"] });
            toast.success("Đã xóa slot thành công");
        }
    });

    const getFilteredAndSortedSlots = () => {
        let list = [...slots];
        
        if (viewMode === "today") {
            const today = format(new Date(), "yyyy-MM-dd");
            list = list.filter((s: Slot) => {
                const sDate = parseDateString(s.startTime);
                return sDate && format(sDate, "yyyy-MM-dd") === today;
            });
        } else if (viewMode === "tomorrow") {
            const tomorrow = format(addDays(new Date(), 1), "yyyy-MM-dd");
            list = list.filter((s: Slot) => {
                const sDate = parseDateString(s.startTime);
                return sDate && format(sDate, "yyyy-MM-dd") === tomorrow;
            });
        } else if (viewMode === "custom") {
            list = list.filter((s: Slot) => {
                const sDate = parseDateString(s.startTime);
                return sDate && format(sDate, "yyyy-MM-dd") === date;
            });
        }
        
        return list.sort((a, b) => {
            const dateA = parseDateString(a.startTime);
            const dateB = parseDateString(b.startTime);
            if (!dateA || !dateB) return 0;
            return dateA.getTime() - dateB.getTime();
        });
    };

    const finalSlots = getFilteredAndSortedSlots();

    // Grouping slots by date for the "line to separate each days"
    const groupedSlots: { [key: string]: Slot[] } = finalSlots.reduce((acc, slot) => {
        const dateStr = slot.startTime.split(' ')[1]; // dd/MM/yyyy
        if (!acc[dateStr]) acc[dateStr] = [];
        acc[dateStr].push(slot);
        return acc;
    }, {} as { [key: string]: Slot[] });

    const sortedDates = Object.keys(groupedSlots).sort((a, b) => {
        const dA = parse(a, "dd/MM/yyyy", new Date());
        const dB = parse(b, "dd/MM/yyyy", new Date());
        return dA.getTime() - dB.getTime();
    });

    return (
        <TeacherLayout>
            <div className="p-6 max-w-6xl mx-auto min-h-screen transition-colors duration-300">
                <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
                    <div>
                        <h1 className="text-2xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
                            <Calendar className="w-6 h-6 text-blue-600 dark:text-blue-400" />
                            Quản lý Lịch dạy
                        </h1>
                        <p className="text-gray-500 dark:text-gray-400">Mở và quản lý các khung giờ dạy tiếng Anh online</p>
                    </div>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    {/* Left Column: Form */}
                    <div className="lg:col-span-1">
                        <div className="bg-white dark:bg-gray-800 p-6 rounded-2xl shadow-xl shadow-blue-500/5 border border-gray-100 dark:border-gray-700 sticky top-6">
                            <h2 className="text-lg font-semibold mb-6 flex items-center gap-2 dark:text-white">
                                <Plus className="w-5 h-5 text-blue-500 dark:text-blue-400" />
                                Mở Slot mới
                            </h2>
                            <div className="space-y-5">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Ngày giảng dạy</label>
                                    <input 
                                        type="date" 
                                        value={date}
                                        onChange={(e) => {
                                            console.log("[TeachingSchedule] Creation date changed to:", e.target.value);
                                            setDate(e.target.value);
                                        }}
                                        className="w-full px-4 py-2 border rounded-xl focus:ring-2 focus:ring-blue-500 bg-white dark:bg-gray-700 dark:border-gray-600 dark:text-white transition-all"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Thời gian bắt đầu</label>
                                    <input 
                                        type="time" 
                                        value={startTime}
                                        onChange={(e) => setStartTime(e.target.value)}
                                        className="w-full px-4 py-2 border rounded-xl focus:ring-2 focus:ring-blue-500 bg-white dark:bg-gray-700 dark:border-gray-600 dark:text-white transition-all"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Thời gian kết thúc</label>
                                    <input 
                                        type="time" 
                                        value={endTime}
                                        onChange={(e) => setEndTime(e.target.value)}
                                        className="w-full px-4 py-2 border rounded-xl focus:ring-2 focus:ring-blue-500 bg-white dark:bg-gray-700 dark:border-gray-600 dark:text-white transition-all"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Thời lượng (phút)</label>
                                    <select 
                                        value={duration}
                                        onChange={(e) => setDuration(Number(e.target.value))}
                                        className="w-full px-4 py-2 border rounded-xl focus:ring-2 focus:ring-blue-500 bg-white dark:bg-gray-700 dark:border-gray-600 dark:text-white transition-all appearance-none"
                                    >
                                        <option value={15}>15 phút</option>
                                        <option value={30}>30 phút</option>
                                        <option value={45}>45 phút</option>
                                        <option value={60}>60 phút</option>
                                    </select>
                                </div>
                                <button
                                    onClick={() => createSlotsMutation.mutate()}
                                    disabled={createSlotsMutation.isPending || !isDateValidForCreation || isOverlapping}
                                    className="w-full bg-blue-600 hover:bg-blue-700 active:scale-[0.98] text-white font-semibold py-3.5 rounded-xl transition-all duration-200 mt-4 disabled:bg-gray-300 dark:disabled:bg-gray-700 disabled:cursor-not-allowed shadow-lg shadow-blue-500/20"
                                >
                                    {createSlotsMutation.isPending ? "Đang xử lý..." : "Mở Slot Dạy"}
                                </button>
                                {!isDateValidForCreation && (
                                    <p className="text-xs text-red-500 mt-2 text-center font-medium animate-pulse">
                                        * Phải đăng ký trước ít nhất 1 ngày (từ {format(addDays(new Date(), 1), "dd/MM/yyyy")})
                                    </p>
                                )}
                                {isDateValidForCreation && isOverlapping && (
                                    <p className="text-xs text-orange-500 mt-2 text-center font-medium animate-pulse">
                                        * Thời gian này trùng với lịch đã có.
                                    </p>
                                )}
                            </div>
                        </div>
                    </div>

                    {/* Right Column: List & Filter */}
                    <div className="lg:col-span-2">
                        <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-xl shadow-blue-500/5 border border-gray-100 dark:border-gray-700 overflow-hidden">
                            {/* Navigation Tabs/Filter */}
                            <div className="p-2 bg-gray-50 dark:bg-gray-900/50 border-b dark:border-gray-700 flex flex-wrap gap-2 transition-colors">
                                <button 
                                    onClick={() => setViewMode("today")}
                                    className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all ${viewMode === 'today' ? 'bg-blue-600 text-white shadow-lg shadow-blue-500/20' : 'text-gray-500 hover:bg-gray-200 dark:hover:bg-gray-700'}`}
                                >
                                    Hôm nay
                                </button>
                                <button 
                                    onClick={() => setViewMode("tomorrow")}
                                    className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all ${viewMode === 'tomorrow' ? 'bg-blue-600 text-white shadow-lg shadow-blue-500/20' : 'text-gray-500 hover:bg-gray-200 dark:hover:bg-gray-700'}`}
                                >
                                    Ngày mai
                                </button>
                                <button 
                                    onClick={() => setViewMode("all")}
                                    className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all ${viewMode === 'all' ? 'bg-blue-600 text-white shadow-lg shadow-blue-500/20' : 'text-gray-500 hover:bg-gray-200 dark:hover:bg-gray-700'}`}
                                >
                                    Tất cả
                                </button>
                                <button 
                                    onClick={() => setViewMode("custom")}
                                    className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all ${viewMode === 'custom' ? 'bg-blue-600 text-white shadow-lg shadow-blue-500/20' : 'text-gray-500 hover:bg-gray-200 dark:hover:bg-gray-700'}`}
                                >
                                    {viewMode === 'custom' ? `Ngày: ${format(parse(date, "yyyy-MM-dd", new Date()), "dd/MM")}` : "Theo ngày"}
                                </button>
                                
                                <div className="ml-auto flex items-center px-2 text-xs font-mono text-gray-400">
                                    {isError ? "Lỗi tải dữ liệu" : `${finalSlots.length} slots`}
                                </div>
                            </div>
                            
                            {isError && (
                                <div className="p-12 text-center text-red-500">
                                    Có lỗi xảy ra khi tải lịch trình. Vui lòng thử lại sau.
                                </div>
                            )}
                            
                            {!isError && (isLoading ? (
                                <div className="p-12 text-center text-gray-500 dark:text-gray-400">
                                    <div className="animate-spin w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full mx-auto mb-4"></div>
                                    Đang tải lịch trình...
                                </div>
                            ) : finalSlots.length === 0 ? (
                                <div className="p-16 text-center">
                                    <div className="bg-blue-50 dark:bg-blue-900/20 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6">
                                        <Clock className="w-10 h-10 text-blue-300 dark:text-blue-700" />
                                    </div>
                                    <h3 className="text-gray-900 dark:text-white font-semibold text-lg">Chưa có slot dạy nào cho {
                                        viewMode === 'today' ? "hôm nay" : 
                                        viewMode === 'tomorrow' ? "ngày mai" : 
                                        viewMode === 'custom' ? `ngày ${format(parse(date, "yyyy-MM-dd", new Date()), "dd/MM/yyyy")}` : "khoảng thời gian này"
                                    }</h3>
                                    <p className="text-gray-500 dark:text-gray-400 mt-2">
                                        {upcomingSlotsCount > 0 
                                            ? `Bạn đang có ${upcomingSlotsCount} slot ở các ngày khác. Hãy chọn "Tất cả" để xem.`
                                            : "Hãy mở slot để học viên có thể tìm thấy bạn."}
                                    </p>
                                </div>
                            ) : (
                                <div className="divide-y dark:divide-gray-700 animate-in fade-in slide-in-from-bottom-2 duration-500">
                                    {sortedDates.map(dateStr => (
                                        <div key={dateStr}>
                                            {/* Day Separator / Header */}
                                            <div className="bg-gray-50/50 dark:bg-gray-800/50 px-5 py-2 text-xs font-bold text-blue-600 dark:text-blue-400 uppercase tracking-wider border-y dark:border-gray-700 flex items-center gap-2">
                                                <Calendar className="w-3 h-3" />
                                                Ngày {dateStr}
                                            </div>
                                            
                                            <div className="divide-y dark:divide-gray-700">
                                                {groupedSlots[dateStr].map((slot: Slot) => (
                                                    <div key={slot.id} className="p-5 flex items-center justify-between hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors group">
                                                        <div className="flex items-center gap-5">
                                                <div className="bg-blue-50 dark:bg-blue-900/30 p-3 rounded-xl text-blue-600 dark:text-blue-400 font-mono font-bold text-lg shadow-sm">
                                                    {slot.startTime.split(' ')[0]}
                                                </div>
                                                <div>
                                                    <div className="flex items-center gap-3">
                                                        <span className={`text-xs font-bold px-2.5 py-1 rounded-full ${
                                                            slot.status === 'AVAILABLE' ? 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400' :
                                                            slot.status === 'BOOKED' ? 'bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400' :
                                                            'bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-400'
                                                        }`}>
                                                            {slot.status === 'AVAILABLE' ? "SẴN SÀNG" : 
                                                             slot.status === 'BOOKED' ? "ĐÃ ĐẶT" : slot.status}
                                                        </span>
                                                        {slot.status === 'BOOKED' && (
                                                            <span className="text-sm text-gray-600 dark:text-gray-300 flex items-center gap-1.5 font-medium">
                                                                <User className="w-4 h-4 text-gray-400" />
                                                                {slot.studentName || "Học viên"}
                                                            </span>
                                                        )}
                                                    </div>
                                                    <p className="text-xs text-gray-400 dark:text-gray-500 mt-1.5">Thời gian: {slot.startTime} - {slot.endTime}</p>
                                                </div>
                                            </div>
                                            <div className="flex items-center gap-3">
                                                {slot.status === 'AVAILABLE' && (
                                                    <button 
                                                        onClick={() => {
                                                            console.log("[TeachingSchedule] Deleting slot with id:", slot.id);
                                                            deleteSlotMutation.mutate(slot.id);
                                                        }}
                                                        className="p-2.5 text-gray-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-all"
                                                        title="Hủy slot"
                                                    >
                                                        <Trash2 className="w-5 h-5" />
                                                    </button>
                                                )}
                                                {slot.status === 'BOOKED' && (
                                                    <button 
                                                        className="bg-green-600 px-5 py-2.5 rounded-xl text-white text-sm font-bold hover:bg-green-700 shadow-lg shadow-green-500/20 active:scale-[0.98] transition-all"
                                                        onClick={() => console.log("[TeachingSchedule] Start teaching session for slot:", slot.id)}
                                                    >
                                                        Bắt đầu dạy
                                                    </button>
                                                )}
                                            </div>
                                        </div>
                                                ))}
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </div>
        </TeacherLayout>
    );
}
