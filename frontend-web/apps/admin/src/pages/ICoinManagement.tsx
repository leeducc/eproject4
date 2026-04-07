import { useState, useEffect } from "react";
import { RefreshCw, AlertCircle } from "lucide-react";
import { AdminLayout } from "../components/AdminLayout";

import { apiClient } from "@english-learning/api";

interface Transaction {
    id: number;
    userId: number;
    userName: string | null;
    userEmail: string;
    amount: number;
    transactionType: "ADD" | "DEDUCT" | "SET";
    description: string;
    balanceAfter: number | null;
    createdAt: string;
}

const TYPE_STYLES: Record<string, string> = {
    ADD: "bg-green-100 text-green-700",
    DEDUCT: "bg-red-100 text-red-700",
    SET: "bg-blue-100 text-blue-700",
};

export default function ICoinManagement() {
    const [transactions, setTransactions] = useState<Transaction[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    
    const [userId, setUserId] = useState("");
    const [amount, setAmount] = useState("");
    const [action, setAction] = useState("ADD");
    const [submitLoading, setSubmitLoading] = useState(false);
    const [message, setMessage] = useState<{ type: "success" | "error"; text: string } | null>(null);

    const fetchTransactions = async () => {
        setIsLoading(true);
        setError(null);
        console.log("[iCoin] Fetching transactions...");

        try {
            const res = await apiClient.get<Transaction[]>("/admin/icoin/transactions");
            console.log("[iCoin] GET /admin/icoin/transactions status:", res.status);
            setTransactions(res.data);
            console.log("[iCoin] Loaded", res.data.length, "transactions");
        } catch (err: any) {
            console.error("[iCoin] Failed to fetch transactions:", err);
            setError(err.response?.data?.message || err.message || String(err));
        } finally {
            setIsLoading(false);
        }
    };

    useEffect(() => {
        fetchTransactions();
    }, []);

    const handleSubmit = async () => {
        console.log("[iCoin] Submit clicked", { userId, amount, action });
        if (!userId.trim()) { setMessage({ type: "error", text: "Please enter a User ID." }); return; }
        if (!amount || Number(amount) <= 0) { setMessage({ type: "error", text: "Please enter a valid amount > 0." }); return; }

        const method = action === "SET" ? "put" : "post";
        const url = `/admin/users/${userId}/icoin/${action.toLowerCase()}`;
        const body = { amount: Number(amount), description: `Admin ${action} via dashboard` };
        console.log("[iCoin]", method.toUpperCase(), url, body);

        setSubmitLoading(true);
        setMessage(null);
        try {
            const res = await (apiClient as any)[method](url, body);
            console.log("[iCoin] Submit response:", res.status);
            setMessage({ type: "success", text: `${action} of ${amount} iCoins applied to user #${userId}.` });
            setUserId(""); setAmount("");
            fetchTransactions(); 
        } catch (err: any) {
            console.error("[iCoin] Submit error:", err);
            const errText = err.response?.data?.message || err.message || String(err);
            setMessage({ type: "error", text: `Error: ${errText}` });
        } finally {
            setSubmitLoading(false);
        }
    };

    const formatDate = (iso: string) =>
        new Date(iso).toLocaleString("en-GB", { dateStyle: "short", timeStyle: "short" });

    return (
        <AdminLayout>
            <div className="space-y-6">
                {}
                <div className="bg-white dark:bg-slate-900 rounded-2xl p-6 border border-gray-100 dark:border-slate-800 shadow-sm">
                    <h3 className="font-semibold text-gray-800 dark:text-slate-100 text-xl mb-5">Adjust User iCoin Balance</h3>

                    {message && (
                        <div className={`mb-4 px-4 py-3 rounded-lg text-sm font-medium ${message.type === "success" ? "bg-green-50 dark:bg-green-900/20 text-green-700 dark:text-green-400 border border-green-200 dark:border-green-800" : "bg-red-50 dark:bg-red-900/20 text-red-700 dark:text-red-400 border border-red-200 dark:border-red-800"}`}>
                            {message.text}
                        </div>
                    )}

                    <div className="flex gap-4 items-end flex-wrap">
                        <div className="flex-1 min-w-[140px]">
                            <label className="block text-sm text-gray-600 dark:text-slate-400 mb-1">User ID</label>
                            <input id="icoin-user-id" type="text" value={userId} onChange={(e) => setUserId(e.target.value)}
                                className="w-full px-4 py-2 rounded-lg border border-gray-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-gray-800 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-primary/20 transition-colors" placeholder="e.g. 1" />
                        </div>
                        <div className="flex-1 min-w-[140px]">
                            <label className="block text-sm text-gray-600 dark:text-slate-400 mb-1">Amount</label>
                            <input id="icoin-amount" type="number" value={amount} onChange={(e) => setAmount(e.target.value)}
                                className="w-full px-4 py-2 rounded-lg border border-gray-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-gray-800 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-primary/20 transition-colors" placeholder="e.g. 100" />
                        </div>
                        <div className="flex-1 min-w-[120px]">
                            <label className="block text-sm text-gray-600 dark:text-slate-400 mb-1">Action</label>
                            <select id="icoin-action" value={action} onChange={(e) => setAction(e.target.value)}
                                className="w-full px-4 py-2 rounded-lg border border-gray-200 dark:border-slate-700 focus:outline-none focus:ring-2 focus:ring-primary/20 bg-white dark:bg-slate-800 text-gray-800 dark:text-slate-100 transition-colors">
                                <option>ADD</option>
                                <option>DEDUCT</option>
                                <option>SET</option>
                            </select>
                        </div>
                        <button id="icoin-submit-btn" onClick={handleSubmit} disabled={submitLoading}
                            className="bg-primary text-white px-6 py-2 rounded-lg font-medium hover:bg-primary/90 transition-colors disabled:opacity-60 disabled:cursor-not-allowed">
                            {submitLoading ? "Submitting..." : "Submit"}
                        </button>
                    </div>
                </div>

                {}
                <div className="bg-white dark:bg-slate-900 rounded-2xl p-6 border border-gray-100 dark:border-slate-800 shadow-sm">
                    <div className="flex justify-between items-center mb-5">
                        <h3 className="font-semibold text-gray-800 dark:text-slate-100 text-xl">iCoin Transaction History</h3>
                        <button onClick={fetchTransactions} title="Refresh"
                            className="text-gray-400 hover:text-primary transition-colors">
                            <RefreshCw size={18} className={isLoading ? "animate-spin" : ""} />
                        </button>
                    </div>

                    {error && (
                        <div className="flex items-center gap-2 text-red-600 dark:text-red-400 text-sm mb-4 bg-red-50 dark:bg-red-900/20 p-3 rounded-lg border border-red-200 dark:border-red-800">
                            <AlertCircle size={16} /> {error}
                        </div>
                    )}

                    {isLoading ? (
                        <div className="flex justify-center py-12 text-gray-400 text-sm">Loading transactions...</div>
                    ) : transactions.length === 0 ? (
                        <div className="flex justify-center py-12 text-gray-400 text-sm">No transactions found.</div>
                    ) : (
                        <div className="overflow-x-auto">
                            <table className="w-full text-left border-collapse text-sm">
                                <thead>
                                    <tr className="border-b border-gray-100 dark:border-slate-800 text-gray-500 dark:text-slate-400 font-medium">
                                        <th className="py-3 px-4">Transaction ID</th>
                                        <th className="py-3 px-4">Date / Time</th>
                                        <th className="py-3 px-4">User</th>
                                        <th className="py-3 px-4">Type</th>
                                        <th className="py-3 px-4">Amount</th>
                                        <th className="py-3 px-4">Description</th>
                                        <th className="py-3 px-4">Balance After</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {transactions.map((t) => (
                                        <tr key={t.id} className="border-b border-gray-50 dark:border-slate-800/50 hover:bg-gray-50 dark:hover:bg-slate-800/40 transition-colors">
                                            <td className="py-3 px-4 font-medium text-gray-800 dark:text-slate-200">#{t.id}</td>
                                            <td className="py-3 px-4 text-gray-500">{t.createdAt ? formatDate(t.createdAt) : "—"}</td>
                                            <td className="py-3 px-4">
                                                <p className="font-medium text-gray-800 dark:text-slate-200">{t.userName ?? "—"}</p>
                                                <p className="text-xs text-gray-400 dark:text-slate-500">{t.userEmail}</p>
                                            </td>
                                            <td className="py-3 px-4">
                                                <span className={`px-2 py-0.5 rounded-full text-xs font-bold ${TYPE_STYLES[t.transactionType] ? `${TYPE_STYLES[t.transactionType]} dark:bg-opacity-20` : "bg-gray-100 dark:bg-slate-800 text-gray-600 dark:text-slate-400"}`}>
                                                    {t.transactionType}
                                                </span>
                                            </td>
                                            <td className={`py-3 px-4 font-semibold ${t.transactionType === "DEDUCT" ? "text-red-600 dark:text-red-400" : "text-green-600 dark:text-green-400"}`}>
                                                {t.transactionType === "DEDUCT" ? "-" : "+"}{t.amount}
                                            </td>
                                            <td className="py-3 px-4 text-gray-600 dark:text-slate-400 max-w-[200px] truncate">{t.description ?? "—"}</td>
                                            <td className="py-3 px-4 font-medium text-gray-800 dark:text-slate-200">
                                                {t.balanceAfter != null ? `${t.balanceAfter} iCoins` : "—"}
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    )}
                </div>
            </div>
        </AdminLayout>
    );
}
