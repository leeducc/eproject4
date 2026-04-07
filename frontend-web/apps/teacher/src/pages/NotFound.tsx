import { useNavigate } from "react-router-dom";
import { MoveLeft, Home, AlertCircle } from "lucide-react";
import { useEffect } from "react";

const NotFound = () => {
    const navigate = useNavigate();

    useEffect(() => {
        console.log("[NotFound] Teacher Page loaded - invalid URL accessed.");
    }, []);

    return (
        <div className="min-h-screen flex items-center justify-center bg-white dark:bg-slate-950 p-6 transition-colors duration-500">
            {}
            <div className="fixed inset-0 overflow-hidden pointer-events-none">
                <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-emerald-400/10 blur-[120px] dark:bg-emerald-600/5" />
                <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full bg-teal-400/10 blur-[120px] dark:bg-teal-600/5" />
            </div>

            <div className="relative z-10 max-w-2xl w-full text-center">
                <div className="mb-8 flex justify-center">
                    <div className="relative">
                        <div className="absolute inset-0 bg-emerald-500/20 blur-2xl rounded-full scale-150 animate-pulse" />
                        <div className="relative bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 p-6 rounded-3xl shadow-xl">
                            <AlertCircle className="w-16 h-16 text-emerald-500" />
                        </div>
                    </div>
                </div>

                <h1 className="text-8xl md:text-9xl font-black text-slate-900 dark:text-white mb-4 tracking-tighter">
                    404
                </h1>
                
                <h2 className="text-2xl md:text-3xl font-bold text-slate-800 dark:text-slate-100 mb-6">
                    Page Not Found
                </h2>

                <p className="text-slate-600 dark:text-slate-400 text-lg mb-12 max-w-md mx-auto leading-relaxed">
                    The page you are looking for might have been removed, had its name changed, or is temporarily unavailable.
                </p>

                <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
                    <button
                        onClick={() => navigate(-1)}
                        className="group flex items-center gap-2 px-8 py-4 bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-slate-900 dark:text-white font-semibold rounded-2xl transition-all duration-300 border border-slate-200 dark:border-slate-700 w-full sm:w-auto justify-center"
                    >
                        <MoveLeft className="w-5 h-5 group-hover:-translate-x-1 transition-transform" />
                        Go Back
                    </button>
                    
                    <button
                        onClick={() => navigate("/teacher/dashboard")}
                        className="group flex items-center gap-2 px-8 py-4 bg-emerald-600 hover:bg-emerald-700 text-white font-semibold rounded-2xl transition-all duration-300 shadow-lg shadow-emerald-500/25 hover:shadow-emerald-500/40 w-full sm:w-auto justify-center"
                    >
                        <Home className="w-5 h-5 group-hover:scale-110 transition-transform" />
                        Dashboard
                    </button>
                </div>

                <div className="mt-16 pt-8 border-t border-slate-100 dark:border-slate-800/50">
                    <p className="text-sm text-slate-400 dark:text-slate-500">
                        If you think this is a mistake, please contact support.
                    </p>
                </div>
            </div>
        </div>
    );
};

export default NotFound;
