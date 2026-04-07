import { AlertTriangle, RefreshCw, Home } from "lucide-react";

interface ErrorUIProps {
  error?: Error;
  resetErrorBoundary?: () => void;
  title?: string;
  message?: string;
}

export const ErrorUI: React.FC<ErrorUIProps> = ({
  error,
  resetErrorBoundary,
  title = "Something went wrong",
  message = "An unexpected error occurred. Our team has been notified and is working to fix it.",
}) => {
  console.log("[ErrorUI] Rendered error:", error?.message);

  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-50 dark:bg-slate-950 p-6 transition-colors duration-500">
      {/* Dynamic Background Accents */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-[-5%] left-[-5%] w-[45%] h-[45%] rounded-full bg-rose-500/10 blur-[120px] dark:bg-rose-600/5 animate-pulse" />
        <div className="absolute bottom-[-5%] right-[-5%] w-[45%] h-[45%] rounded-full bg-orange-500/10 blur-[120px] dark:bg-orange-600/5" />
      </div>

      <div className="relative z-10 max-w-xl w-full">
        <div className="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-[2.5rem] shadow-2xl shadow-slate-200/50 dark:shadow-none overflow-hidden">
          <div className="p-8 md:p-12 text-center">
            {/* Icon Stage */}
            <div className="mb-8 flex justify-center">
              <div className="relative">
                <div className="absolute inset-0 bg-rose-500/20 blur-2xl rounded-full scale-150 animate-pulse" />
                <div className="relative bg-rose-50 dark:bg-rose-950/30 border border-rose-100 dark:border-rose-900/50 p-6 rounded-3xl shadow-sm">
                  <AlertTriangle className="w-12 h-12 text-rose-500" />
                </div>
              </div>
            </div>

            {/* Content */}
            <h1 className="text-3xl md:text-4xl font-extrabold text-slate-900 dark:text-white mb-4 tracking-tight">
              {title}
            </h1>
            
            <p className="text-slate-600 dark:text-slate-400 text-lg mb-10 leading-relaxed mx-auto max-w-sm">
              {message}
            </p>

            {error && (
              <div className="mb-10 p-4 bg-slate-50 dark:bg-slate-800/50 rounded-2xl border border-slate-100 dark:border-slate-800 text-left overflow-hidden">
                <p className="text-xs font-mono text-slate-500 dark:text-slate-500 uppercase tracking-wider mb-2 font-bold">Error Details</p>
                <p className="text-sm font-mono text-rose-600 dark:text-rose-400 break-words line-clamp-3">
                  {error.name}: {error.message}
                </p>
              </div>
            )}

            {/* Actions */}
            <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
              {resetErrorBoundary && (
                <button
                  onClick={resetErrorBoundary}
                  className="group flex items-center gap-2 px-8 py-4 bg-slate-900 dark:bg-white hover:bg-slate-800 dark:hover:bg-slate-100 text-white dark:text-slate-900 font-bold rounded-2xl transition-all duration-300 shadow-lg hover:translate-y-[-2px] w-full sm:w-auto justify-center"
                >
                  <RefreshCw className="w-5 h-5 group-hover:rotate-180 transition-transform duration-500" />
                  Try Again
                </button>
              )}
              
              <button
                onClick={() => (window.location.href = "/admin/dashboard")}
                className="group flex items-center gap-2 px-8 py-4 bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 hover:border-slate-300 dark:hover:border-slate-600 text-slate-900 dark:text-white font-bold rounded-2xl transition-all duration-300 shadow-sm hover:translate-y-[-2px] w-full sm:w-auto justify-center"
              >
                <Home className="w-5 h-5 group-hover:scale-110 transition-transform" />
                Go Home
              </button>
            </div>
          </div>

          {/* Footer Branding/Info */}
          <div className="bg-slate-50/50 dark:bg-slate-800/30 px-8 py-4 border-t border-slate-100 dark:border-slate-800/50">
            <p className="text-center text-xs text-slate-400 dark:text-slate-500">
              English Learning Platform • Admin Dashboard
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};
