import React, { useEffect, useState } from "react";
import { X, Clock, User, ChevronRight, FileText } from "lucide-react";
import { getPolicyHistory, PolicyHistory } from "@english-learning/api";
import { toast } from "@english-learning/ui";

interface PolicyHistoryModalProps {
  isOpen: boolean;
  onClose: () => void;
  type: string;
  policyName: string;
}

export const PolicyHistoryModal: React.FC<PolicyHistoryModalProps> = ({ 
  isOpen, 
  onClose, 
  type,
  policyName 
}) => {
  const [history, setHistory] = useState<PolicyHistory[]>([]);
  const [loading, setLoading] = useState(false);
  const [selectedVersion, setSelectedVersion] = useState<PolicyHistory | null>(null);

  useEffect(() => {
    if (isOpen) {
      console.log(`[PolicyHistoryModal] Fetching history for ${type}`);
      fetchHistory();
    }
  }, [isOpen, type]);

  const fetchHistory = async () => {
    setLoading(true);
    try {
      const data = await getPolicyHistory(type);
      console.log(`[PolicyHistoryModal] Successfully fetched ${data.length} history records`);
      setHistory(data);
    } catch (e) {
      console.error(e);
      toast.error("Failed to load revision history");
    } finally {
      setLoading(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="bg-white dark:bg-slate-900 rounded-xl shadow-2xl max-w-5xl w-full overflow-hidden animate-in zoom-in-95 duration-200 border dark:border-slate-800 flex flex-col max-h-[90vh]">
        <div className="px-6 py-4 border-b dark:border-slate-800 flex justify-between items-center bg-gray-50 dark:bg-slate-800/50">
          <h3 className="text-xl font-bold flex items-center">
            <Clock className="mr-2 text-blue-600" size={20} /> {policyName} Revision History
          </h3>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
            <X size={20} />
          </button>
        </div>

        <div className="flex flex-1 overflow-hidden">
          {}
          <div className="w-1/3 border-r dark:border-slate-800 overflow-y-auto bg-gray-50/50 dark:bg-slate-900">
            {loading ? (
              <div className="p-8 text-center text-gray-500">Loading history...</div>
            ) : history.length === 0 ? (
              <div className="p-8 text-center text-gray-500">No revisions found for this policy.</div>
            ) : (
              <div className="divide-y dark:divide-slate-800">
                {history.map((record, index) => (
                  <button
                    key={record.id}
                    onClick={() => {
                        console.log(`[PolicyHistoryModal] Selected version ID: ${record.id}`);
                        setSelectedVersion(record);
                    }}
                    className={`w-full text-left p-4 hover:bg-blue-50 dark:hover:bg-blue-900/20 transition-colors flex items-start gap-3 ${
                      selectedVersion?.id === record.id ? "bg-blue-50 dark:bg-blue-900/30 border-l-4 border-blue-600" : ""
                    }`}
                  >
                    <div className={`mt-1 p-2 rounded-full ${index === 0 ? "bg-green-100 text-green-600" : "bg-gray-100 text-gray-600"}`}>
                      <FileText size={16} />
                    </div>
                    <div className="flex-1 overflow-hidden">
                      <p className="font-semibold text-sm truncate">
                        {index === 0 ? "Current Version" : `Revision #${history.length - index}`}
                      </p>
                      <p className="text-xs text-gray-500 mt-0.5 flex items-center">
                        <Clock size={12} className="mr-1" /> {new Date(record.changedAt).toLocaleString()}
                      </p>
                      <p className="text-xs text-gray-500 mt-1 flex items-center">
                        <User size={12} className="mr-1" /> {record.adminEmail}
                      </p>
                    </div>
                    <ChevronRight size={16} className="text-gray-400 self-center" />
                  </button>
                ))}
              </div>
            )}
          </div>

          {}
          <div className="flex-1 overflow-y-auto p-6 bg-white dark:bg-slate-900">
            {selectedVersion ? (
              <div className="animate-in fade-in slide-in-from-right-4 duration-300">
                <div className="mb-6 pb-6 border-b dark:border-slate-800">
                  <h4 className="text-lg font-bold text-gray-900 dark:text-white capitalize">
                    {selectedVersion.type.replace("_", " ")} - {selectedVersion.titleEn}
                  </h4>
                  <div className="flex gap-4 mt-2">
                    <span className="text-xs bg-gray-100 dark:bg-slate-800 px-2 py-1 rounded text-gray-600 dark:text-gray-400">
                      ID: {selectedVersion.id}
                    </span>
                    <span className="text-xs bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-300 px-2 py-1 rounded">
                      Changed by: {selectedVersion.adminEmail}
                    </span>
                  </div>
                </div>

                <div className="space-y-8">
                  <div>
                    <h5 className="text-xs font-bold uppercase tracking-wider text-gray-400 mb-3 flex items-center">
                        <span className="w-8 h-px bg-gray-200 mr-2"></span> English Content
                    </h5>
                    <div 
                      className="prose prose-sm max-w-none dark:prose-invert p-4 border dark:border-slate-800 rounded-lg bg-gray-50/30"
                      dangerouslySetInnerHTML={{ __html: selectedVersion.contentEn }}
                    />
                  </div>

                  <div>
                    <h5 className="text-xs font-bold uppercase tracking-wider text-gray-400 mb-3 flex items-center">
                        <span className="w-8 h-px bg-gray-200 mr-2"></span> Vietnamese Content
                    </h5>
                    <div 
                      className="prose prose-sm max-w-none dark:prose-invert p-4 border dark:border-slate-800 rounded-lg bg-gray-50/30"
                      dangerouslySetInnerHTML={{ __html: selectedVersion.contentVi }}
                    />
                  </div>
                </div>
              </div>
            ) : (
              <div className="h-full flex flex-col items-center justify-center text-gray-400 space-y-4">
                <FileText size={64} strokeWidth={1} />
                <p>Select a version from the left list to view details.</p>
              </div>
            )}
          </div>
        </div>

        <div className="p-4 border-t dark:border-slate-800 flex justify-end bg-gray-50 dark:bg-slate-800/50">
          <button
            onClick={onClose}
            className="px-6 py-2 bg-white text-gray-700 border border-gray-200 rounded-lg hover:bg-gray-100 transition shadow-sm font-semibold text-sm"
          >
            Close History
          </button>
        </div>
      </div>
    </div>
  );
};
