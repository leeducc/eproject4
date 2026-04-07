import React, { useState, useEffect, useRef } from "react";
import SockJS from "sockjs-client";
import Stomp from "stompjs";
import { toast } from "sonner";
import { Bell, Phone, User, X, Check, Star } from "lucide-react";
import { useWebRTC } from "./hooks/useWebRTC";

interface MatchInfo {
    studentId: number;
    teacherId: number;
    type: string;
    message?: string;
    sessionId?: number;
}

export const InstantTutoringTeacher: React.FC<{ teacherId: number }> = ({ teacherId }) => {
    const [isReady, setIsReady] = useState(false);
    const [match, setMatch] = useState<MatchInfo | null>(null);
    const [showReviewForm, setShowReviewForm] = useState(false);
    const [reviewContent, setReviewContent] = useState("");
    const stompClientRef = useRef<Stomp.Client | null>(null);
    const audioRef = useRef<HTMLAudioElement | null>(null);
    const localVideoRef = useRef<HTMLVideoElement | null>(null);
    const remoteVideoRef = useRef<HTMLVideoElement | null>(null);

    const { 
        localStream, 
        remoteStream, 
        getLocalMedia, 
        startCall, 
        handleSignal, 
        closeConnection 
    } = useWebRTC(teacherId.toString(), stompClientRef.current);

    useEffect(() => {
        if (localVideoRef.current && localStream) {
            localVideoRef.current.srcObject = localStream;
        }
    }, [localStream]);

    useEffect(() => {
        if (remoteVideoRef.current && remoteStream) {
            remoteVideoRef.current.srcObject = remoteStream;
        }
    }, [remoteStream]);

    useEffect(() => {
        const socket = new SockJS("http://localhost:8123/ws-chat");
        const client = Stomp.over(socket);
        client.debug = () => {}; 

        const token = localStorage.getItem("teacher_token");
        client.connect({ 'Authorization': 'Bearer ' + token }, () => {
            console.log("[Tutoring] Connected to WebSocket");
            
            client.subscribe(`/topic/tutoring-queue/teacher/${teacherId}`, (message) => {
                const data: MatchInfo = JSON.parse(message.body);
                console.log("[Tutoring] Received event:", data);

                if (data.type === "MATCH_FOUND") {
                    setMatch(data);
                    if (audioRef.current) {
                        audioRef.current.play().catch(e => console.warn("Sound play failed", e));
                    }
                    toast.success("Học viên đang đợi bạn!");
                    
                    // Auto-start WebRTC handshake as requested
                    setTimeout(() => {
                        startCall(data.studentId.toString());
                    }, 1000);

                } else if (data.type === "MATCH_ACCEPTED") {
                    toast.success("Buổi học đã bắt đầu!");
                    setMatch(prev => prev ? { ...prev, sessionId: data.sessionId } : data);
                } else if (data.type === "MATCH_TIMEOUT") {
                    toast.error("Học viên không phản hồi kịp.");
                    setMatch(null);
                    closeConnection();
                }
            });

            // Subscribe to WebRTC signaling topic
            client.subscribe('/user/queue/rtc-signal', (message) => {
                const signal = JSON.parse(message.body);
                handleSignal(signal);
            });
        });

        stompClientRef.current = client;

        return () => {
            if (stompClientRef.current?.connected) {
                stompClientRef.current.disconnect(() => {});
            }
        };
    }, [teacherId]);

    const toggleReady = () => {
        if (!stompClientRef.current?.connected) {
            toast.error("WebSocket chưa kết nối.");
            return;
        }

        const newStatus = !isReady;
        setIsReady(newStatus);

        if (newStatus) {
            getLocalMedia(); // Get camera/mic permission when going online
            stompClientRef.current.send("/app/tutoring/teacher/ready", {}, JSON.stringify({}));
            toast.info("Đã bật trạng thái Sẵn sàng nhận lớp. Camera đã sẵn sàng.");
        } else {
            closeConnection();
            toast.warning("Đã tắt trạng thái nhận lớp");
        }
    };

    const handleCallEnd = () => {
        setMatch(null);
        closeConnection();
        setShowReviewForm(true);
    };

    const submitReview = async () => {
        if (!reviewContent.trim()) return;
        
        try {
            const response = await fetch(`http://localhost:8123/api/v1/tutoring/sessions/${match?.sessionId}/review/teacher`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${localStorage.getItem('teacher_token')}`,
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: new URLSearchParams({ privateFeedback: reviewContent })
            });

            if (response.ok) {
                toast.success("Đã gửi nhận xét đến học viên.");
                setShowReviewForm(false);
                setReviewContent("");
            }
        } catch (err) {
            toast.error("Không thể gửi nhận xét.");
        }
    };

    return (
        <div className="bg-white dark:bg-slate-900 rounded-3xl p-6 shadow-xl border border-gray-100 dark:border-slate-800 transition-all duration-500">
            <audio ref={audioRef} src="https://assets.mixkit.co/active_storage/sfx/2358/2358-preview.mp3" preload="auto" />
            
            <div className="flex items-center justify-between gap-6">
                <div className="flex items-center gap-4">
                    <div className={`p-4 rounded-2xl ${isReady ? 'bg-green-500/10 text-green-500' : 'bg-gray-100 dark:bg-slate-800 text-gray-400'}`}>
                        <Bell className={isReady ? 'animate-bounce' : ''} size={32} />
                    </div>
                    <div>
                        <h3 className="text-xl font-black text-gray-900 dark:text-white">Instant Tutoring</h3>
                        <p className="text-sm font-bold opacity-60 uppercase tracking-widest">
                            {isReady ? 'Đang trực tuyến & sẵn sàng' : 'Không nhận lớp'}
                        </p>
                    </div>
                </div>

                <div className="flex items-center gap-3">
                    <span className={`text-sm font-black ${isReady ? 'text-green-500' : 'text-gray-400'}`}>
                        {isReady ? 'READY' : 'OFFLINE'}
                    </span>
                    <button 
                        onClick={toggleReady}
                        className={`relative w-16 h-8 rounded-full transition-all duration-500 p-1 flex items-center ${
                            isReady ? 'bg-green-500 justify-end' : 'bg-gray-300 dark:bg-slate-700 justify-start'
                        }`}
                    >
                        <div className="bg-white w-6 h-6 rounded-full shadow-md transition-all duration-300 transform active:scale-90" />
                    </button>
                </div>
            </div>

            {}
            {match && (
                <div className="mt-8 space-y-6 animate-in zoom-in duration-300">
                    {}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div className="relative aspect-video bg-slate-800 rounded-3xl overflow-hidden shadow-lg border-2 border-primary/20">
                            <video 
                                ref={localVideoRef} 
                                autoPlay 
                                muted 
                                playsInline 
                                className="w-full h-full object-cover mirror"
                            />
                            <div className="absolute bottom-4 left-4 flex gap-2">
                                <div className="px-3 py-1.5 bg-black/50 backdrop-blur-md rounded-full text-[10px] font-black text-white uppercase tracking-widest">
                                    You (Teacher)
                                </div>
                            </div>
                        </div>
                        <div className="relative aspect-video bg-slate-800 rounded-3xl overflow-hidden shadow-lg border-2 border-indigo-500/20">
                            {remoteStream ? (
                                <video 
                                    ref={remoteVideoRef} 
                                    autoPlay 
                                    playsInline 
                                    className="w-full h-full object-cover"
                                />
                            ) : (
                                <div className="w-full h-full flex flex-col items-center justify-center text-gray-500 gap-3">
                                    <div className="w-12 h-12 border-4 border-primary/20 border-t-primary rounded-full animate-spin" />
                                    <p className="text-xs font-bold uppercase tracking-widest">Waiting for student...</p>
                                </div>
                            )}
                            <div className="absolute bottom-4 left-4 flex gap-2">
                                <div className="px-3 py-1.5 bg-black/50 backdrop-blur-md rounded-full text-[10px] font-black text-white uppercase tracking-widest">
                                    Student
                                </div>
                            </div>
                        </div>
                    </div>

                    <div className="bg-indigo-50 dark:bg-indigo-900/20 rounded-3xl p-6 border-2 border-primary/20">
                        <div className="flex items-center gap-6 justify-between">
                            <div className="flex items-center gap-4">
                                <div className="w-16 h-16 bg-primary rounded-2xl flex items-center justify-center text-white shadow-lg">
                                    <User size={32} />
                                </div>
                                <div>
                                    <h4 className="text-lg font-black dark:text-white">Học viên đang đợi</h4>
                                    <p className="text-sm opacity-70">ID: {match.studentId}</p>
                                </div>
                            </div>

                            <div className="flex gap-3">
                                <button 
                                    onClick={handleCallEnd}
                                    className="p-4 bg-red-500 hover:bg-red-600 text-white rounded-2xl shadow-lg transition-transform active:scale-95"
                                >
                                    <X size={24} />
                                </button>
                                <button className="p-4 bg-green-500 hover:bg-green-600 text-white rounded-2xl shadow-lg animate-pulse transition-transform active:scale-95">
                                    <Phone size={24} />
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            )}

            {}
            {showReviewForm && (
                <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-6">
                    <div className="bg-white dark:bg-slate-900 w-full max-w-md rounded-3xl p-8 shadow-2xl border border-gray-100 dark:border-slate-800 animate-in fade-in slide-in-from-bottom-8">
                        <div className="flex items-center gap-3 mb-6">
                            <div className="p-3 bg-primary/10 text-primary rounded-xl">
                                <Star size={24} />
                            </div>
                            <h3 className="text-2xl font-black dark:text-white">Đánh giá học viên</h3>
                        </div>
                        
                        <p className="text-gray-500 dark:text-slate-400 mb-6 font-medium">
                            Hãy viết nhận xét của bạn về học viên vừa rồi. Nhận xét này là riêng tư và chỉ học viên thấy.
                        </p>

                        <textarea 
                            value={reviewContent}
                            onChange={(e) => setReviewContent(e.target.value)}
                            placeholder="Tiến độ học tập, điểm cần cải thiện..."
                            className="w-full bg-gray-50 dark:bg-slate-800 border-none rounded-2xl p-4 min-h-[150px] focus:ring-2 focus:ring-primary/20 text-sm dark:text-white mb-6 font-medium"
                        />

                        <div className="flex gap-3">
                            <button 
                                onClick={() => setShowReviewForm(false)}
                                className="flex-1 py-4 font-black text-gray-500 hover:bg-gray-100 dark:hover:bg-slate-800 rounded-2xl transition-colors"
                            >
                                Đóng
                            </button>
                            <button 
                                onClick={submitReview}
                                className="flex-1 py-4 bg-primary text-white font-black rounded-2xl shadow-lg shadow-primary/20 hover:scale-[1.02] active:scale-[0.98] transition-all flex items-center justify-center gap-2"
                            >
                                <Check size={20} /> Gửi đánh giá
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};
