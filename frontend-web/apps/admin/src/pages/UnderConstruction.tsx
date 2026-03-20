import { RefreshCcw } from "lucide-react";
import { AdminLayout } from "../components/AdminLayout";

export default function UnderConstruction({ title }: { title: string }) {
    return (
        <AdminLayout>
            <div className="flex flex-col items-center justify-center min-h-[60vh] text-center space-y-4">
                <div className="p-6 bg-primary/5 rounded-full animate-pulse">
                    <RefreshCcw size={48} className="text-primary" />
                </div>
                <h1 className="text-3xl font-bold text-gray-900 dark:text-white">{title}</h1>
                <p className="text-gray-500 dark:text-gray-400 max-w-md">
                    We are currently building this feature to give you the best experience. 
                    Please check back later!
                </p>
                <button 
                    onClick={() => window.history.back()}
                    className="px-6 py-2 bg-primary text-white rounded-lg font-medium hover:bg-primary/90 transition-colors"
                >
                    Go Back
                </button>
            </div>
        </AdminLayout>
    );
}
