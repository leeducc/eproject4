import { useState, useEffect } from "react";
import { RefreshCw, AlertCircle } from "lucide-react";
import { AdminLayout } from "../components/AdminLayout";

const API_BASE = "http://localhost/api";
// ... existing Transaction interface and TYPE_STYLES ...
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

    // ── Admin form state ───────────────────────────────────────────────────────
    const [userId, setUserId] = useState("");
    const [amount, setAmount] = useState("");
    const [action, setAction] = useState("ADD");
    const [submitLoading, setSubmitLoading] = useState(false);
    const [message, setMessage] = useState<{ type: "success" | "error"; text: string } | null>(null);

    const fetchTransactions = async () => {
        setIsLoading(true);
        setError(null);
        const token = localStorage.getItem("admin_token");
        console.log("[iCoin] Fetching transactions, token present:", !!token);

        if (!token) {
            setError("Not authenticated. Please log in again.");
            setIsLoading(false);
            return;
        }

        try {
            const res = await fetch(`${API_BASE}/admin/icoin/transactions`, {
                headers: { Authorization: `Bearer ${token}` },
            });
            console.log("[iCoin] GET /admin/icoin/transactions status:", res.status);
            if (!res.ok) throw new Error(`Server responded with ${res.status}`);
            const data: Transaction[] = await res.json();
            console.log("[iCoin] Loaded", data.length, "transactions");
            setTransactions(data);
        } catch (err) {
            console.error("[iCoin] Failed to fetch transactions:", err);
            setError(String(err));
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

        const token = localStorage.getItem("admin_token");
        if (!token) { setMessage({ type: "error", text: "Not authenticated." }); return; }

        const method = action === "SET" ? "PUT" : "POST";
        const url = `${API_BASE}/admin/users/${userId}/icoin/${action.toLowerCase()}`;
        const body = { amount: Number(amount), description: `Admin ${action} via dashboard` };
        console.log("[iCoin]", method, url, body);

        setSubmitLoading(true);
        setMessage(null);
        try {
            const res = await fetch(url, {
                method,
                headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
                body: JSON.stringify(body),
            });
            console.log("[iCoin] Submit response:", res.status);
            if (res.ok) {
                setMessage({ type: "success", text: `${action} of ${amount} iCoins applied to user #${userId}.` });
                setUserId(""); setAmount("");
                fetchTransactions(); // refresh the list
            } else {
                const errText = await res.text();
                setMessage({ type: "error", text: `Error ${res.status}: ${errText}` });
            }
        } catch (err) {
            console.error("[iCoin] Submit error:", err);
            setMessage({ type: "error", text: `Network error: ${String(err)}` });
        } finally {
            setSubmitLoading(false);
        }
    };

    const formatDate = (iso: string) =>
        new Date(iso).toLocaleString("en-GB", { dateStyle: "short", timeStyle: "short" });

    return (
        <AdminLayout>
            <div className="space-y-6">
                {/* ── Adjust Balance Form ─────────────────────────────────────── */}
                <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
                    <h3 className="font-semibold text-gray-800 text-xl mb-5">Adjust User iCoin Balance</h3>

                    {message && (
                        <div className={`mb-4 px-4 py-3 rounded-lg text-sm font-medium ${message.type === "success" ? "bg-green-50 text-green-700 border border-green-200" : "bg-red-50 text-red-700 border border-red-200"}`}>
                            {message.text}
                        </div>
                    )}

                    <div className="flex gap-4 items-end flex-wrap">
                        <div className="flex-1 min-w-[140px]">
                            <label className="block text-sm text-gray-600 mb-1">User ID</label>
                            <input id="icoin-user-id" type="text" value={userId} onChange={(e) => setUserId(e.target.value)}
                                className="w-full px-4 py-2 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/20" placeholder="e.g. 1" />
                        </div>
                        <div className="flex-1 min-w-[140px]">
                            <label className="block text-sm text-gray-600 mb-1">Amount</label>
                            <input id="icoin-amount" type="number" value={amount} onChange={(e) => setAmount(e.target.value)}
                                className="w-full px-4 py-2 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/20" placeholder="e.g. 100" />
                        </div>
                        <div className="flex-1 min-w-[120px]">
                            <label className="block text-sm text-gray-600 mb-1">Action</label>
                            <select id="icoin-action" value={action} onChange={(e) => setAction(e.target.value)}
                                className="w-full px-4 py-2 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/20 bg-white">
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

                {/* ── Transaction History ─────────────────────────────────────── */}
                <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
                    <div className="flex justify-between items-center mb-5">
                        <h3 className="font-semibold text-gray-800 text-xl">iCoin Transaction History</h3>
                        <button onClick={fetchTransactions} title="Refresh"
                            className="text-gray-400 hover:text-primary transition-colors">
                            <RefreshCw size={18} className={isLoading ? "animate-spin" : ""} />
                        </button>
                    </div>

                    {error && (
                        <div className="flex items-center gap-2 text-red-600 text-sm mb-4 bg-red-50 p-3 rounded-lg border border-red-200">
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
                                    <tr className="border-b border-gray-100 text-gray-500">
                                        <th className="py-3 px-4 font-medium">Transaction ID</th>
                                        <th className="py-3 px-4 font-medium">Date / Time</th>
                                        <th className="py-3 px-4 font-medium">User</th>
                                        <th className="py-3 px-4 font-medium">Type</th>
                                        <th className="py-3 px-4 font-medium">Amount</th>
                                        <th className="py-3 px-4 font-medium">Description</th>
                                        <th className="py-3 px-4 font-medium">Balance After</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {transactions.map((t) => (
                                        <tr key={t.id} className="border-b border-gray-50 hover:bg-gray-50 transition-colors">
                                            <td className="py-3 px-4 font-medium text-gray-800">#{t.id}</td>
                                            <td className="py-3 px-4 text-gray-500">{t.createdAt ? formatDate(t.createdAt) : "—"}</td>
                                            <td className="py-3 px-4">
                                                <p className="font-medium text-gray-800">{t.userName ?? "—"}</p>
                                                <p className="text-xs text-gray-400">{t.userEmail}</p>
                                            </td>
                                            <td className="py-3 px-4">
                                                <span className={`px-2 py-0.5 rounded-full text-xs font-bold ${TYPE_STYLES[t.transactionType] ?? "bg-gray-100 text-gray-600"}`}>
                                                    {t.transactionType}
                                                </span>
                                            </td>
                                            <td className={`py-3 px-4 font-semibold ${t.transactionType === "DEDUCT" ? "text-red-600" : "text-green-600"}`}>
                                                {t.transactionType === "DEDUCT" ? "-" : "+"}{t.amount}
                                            </td>
                                            <td className="py-3 px-4 text-gray-600 max-w-[200px] truncate">{t.description ?? "—"}</td>
                                            <td className="py-3 px-4 font-medium text-gray-800">
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
