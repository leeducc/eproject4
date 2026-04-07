import { useQuery } from "@tanstack/react-query";
import { apiClient } from "@english-learning/api";
import { TeacherLayout } from "../components/TeacherLayout";
import { Wallet, ArrowUpCircle, ArrowDownCircle, History, RefreshCcw, Lock } from "lucide-react";

interface Transaction {
    id: number;
    amount: number;
    transactionType: "ADD" | "DEDUCT" | "HOLD" | "COMMIT" | "REFUND";
    description: string;
    balanceAfter: number;
    createdAt: string; 
}

export default function WalletPage() {
    
    const { data: balanceData } = useQuery({
        queryKey: ["icoin-balance"],
        queryFn: async () => {
            const response = await apiClient.get("/icoin/balance");
            return response.data;
        }
    });

    const { data: transactions = [], isLoading } = useQuery<Transaction[]>({
        queryKey: ["icoin-history"],
        queryFn: async () => {
            const response = await apiClient.get("/icoin/history");
            return response.data;
        }
    });

    return (
        <TeacherLayout>
            <div className="p-6 max-w-5xl mx-auto">
                {}
                <div className="bg-gradient-to-r from-blue-600 to-indigo-700 rounded-3xl p-8 text-white shadow-xl mb-10 relative overflow-hidden">
                    <div className="relative z-10">
                        <div className="flex items-center gap-2 opacity-80 mb-2">
                            <Wallet className="w-5 h-5" />
                            <span className="text-sm font-medium uppercase tracking-wider">Số dư Ví Xu</span>
                        </div>
                        <div className="text-5xl font-bold mb-6">
                            {balanceData?.balance?.toLocaleString() || 0} <span className="text-2xl font-normal opacity-80">Xu</span>
                        </div>
                        <div className="flex gap-4">
                            <button className="bg-white/20 hover:bg-white/30 backdrop-blur-md px-6 py-2 rounded-full text-sm font-semibold transition">
                                Nạp thêm Xu
                            </button>
                            <button className="bg-white text-blue-600 px-6 py-2 rounded-full text-sm font-semibold hover:bg-blue-50 transition">
                                Rút tiền
                            </button>
                        </div>
                    </div>
                    {}
                    <div className="absolute -right-20 -bottom-20 w-80 h-80 bg-white/10 rounded-full blur-3xl"></div>
                </div>

                {}
                <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
                    <div className="p-6 border-b flex items-center justify-between">
                        <h2 className="text-xl font-bold text-gray-900 flex items-center gap-2">
                            <History className="w-6 h-6 text-indigo-500" />
                            Lịch sử giao dịch
                        </h2>
                    </div>

                    {isLoading ? (
                        <div className="p-12 text-center text-gray-500">Đang tải lịch sử...</div>
                    ) : transactions.length === 0 ? (
                        <div className="p-12 text-center text-gray-500">Chưa có giao dịch nào.</div>
                    ) : (
                        <div className="overflow-x-auto">
                            <table className="w-full text-left border-collapse">
                                <thead className="bg-gray-50 text-gray-600 text-xs uppercase font-semibold">
                                    <tr>
                                        <th className="px-6 py-4">Thời gian</th>
                                        <th className="px-6 py-4">Nội dung</th>
                                        <th className="px-6 py-4">Loại</th>
                                        <th className="px-6 py-4 text-right">Số xu</th>
                                        <th className="px-6 py-4 text-right">Số dư sau</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-gray-100">
                                    {transactions.map((tx) => (
                                        <tr key={tx.id} className="hover:bg-gray-50 transition">
                                            <td className="px-6 py-4 text-sm text-gray-500 font-mono">
                                                {tx.createdAt}
                                            </td>
                                            <td className="px-6 py-4 text-sm font-medium text-gray-800">
                                                {tx.description}
                                            </td>
                                            <td className="px-6 py-4">
                                                <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold ${
                                                    tx.transactionType === 'ADD' ? 'bg-green-100 text-green-700' :
                                                    tx.transactionType === 'DEDUCT' || tx.transactionType === 'COMMIT' ? 'bg-red-100 text-red-700' :
                                                    tx.transactionType === 'HOLD' ? 'bg-orange-100 text-orange-700' :
                                                    'bg-blue-100 text-blue-700'
                                                }`}>
                                                    {tx.transactionType === 'ADD' && <ArrowUpCircle className="w-3.5 h-3.5" />}
                                                    {tx.transactionType === 'COMMIT' && <ArrowDownCircle className="w-3.5 h-3.5" />}
                                                    {tx.transactionType === 'HOLD' && <Lock className="w-3.5 h-3.5" />}
                                                    {tx.transactionType === 'REFUND' && <RefreshCcw className="w-3.5 h-3.5" />}
                                                    {tx.transactionType}
                                                </span>
                                            </td>
                                            <td className={`px-6 py-4 text-right font-bold ${
                                                tx.transactionType === 'ADD' || tx.transactionType === 'REFUND' 
                                                ? 'text-green-600' : 'text-red-600'
                                            }`}>
                                                {tx.transactionType === 'ADD' || tx.transactionType === 'REFUND' ? '+' : '-'}{tx.amount}
                                            </td>
                                            <td className="px-6 py-4 text-right text-gray-600 font-medium">
                                                {tx.balanceAfter?.toLocaleString()}
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    )}
                </div>
            </div>
        </TeacherLayout>
    );
}
