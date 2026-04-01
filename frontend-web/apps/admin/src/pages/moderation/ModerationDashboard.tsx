import React, { useEffect, useState } from "react";
import { AdminLayout } from "../../components/AdminLayout";
import { 
  getReports, 
  resolveReport, 
  dismissReport, 
  Report, 
  ReportStatus, 
  ReportedItemType 
} from "@english-learning/api";
import { CheckCircle, Trash2, Mail } from "lucide-react";

export const ModerationDashboard: React.FC = () => {
  const [reports, setReports] = useState<Report[]>([]);
  const [activeTab, setActiveTab] = useState<ReportStatus>(ReportStatus.NEW);
  const [selectedReport, setSelectedReport] = useState<Report | null>(null);
  const [isResolveModalOpen, setIsResolveModalOpen] = useState(false);
  const [adminResponse, setAdminResponse] = useState("");
  const [disableContent, setDisableContent] = useState(false);
  const [loading, setLoading] = useState(false);

  const fetchReports = async () => {
    setLoading(true);
    try {
      const data = await getReports(activeTab);
      setReports(data);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReports();
  }, [activeTab]);

  const handleOpenResolve = (report: Report) => {
    setSelectedReport(report);
    setAdminResponse("");
    setDisableContent(false);
    setIsResolveModalOpen(true);
  };

  const handleResolveSubmit = async () => {
    if (!selectedReport) return;
    try {
      await resolveReport(selectedReport.id, {
        adminResponse,
        disableContent
      });
      fetchReports();
      setIsResolveModalOpen(false);
    } catch (e) {
      alert("Failed to resolve report");
    }
  };

  const handleDismiss = async (id: number) => {
    if (window.confirm("Mark this report as spam?")) {
      try {
        await dismissReport(id);
        fetchReports();
      } catch (e) {
        alert("Failed to dismiss report");
      }
    }
  };

  return (
    <AdminLayout title="Moderation Dashboard - EnglishHub">
      <div className="p-6">
        <h1 className="text-2xl font-bold mb-6">Content Moderation</h1>

        <div className="flex space-x-4 mb-6 border-b">
          <button
            onClick={() => setActiveTab(ReportStatus.NEW)}
            className={`pb-2 px-4 ${activeTab === ReportStatus.NEW ? "border-b-2 border-blue-600 text-blue-600 font-medium" : "text-gray-500"}`}
          >
            New Reports
          </button>
          <button
            onClick={() => setActiveTab(ReportStatus.SPAM)}
            className={`pb-2 px-4 ${activeTab === ReportStatus.SPAM ? "border-b-2 border-blue-600 text-blue-600 font-medium" : "text-gray-500"}`}
          >
            Spam / Low Priority
          </button>
          <button
            onClick={() => setActiveTab(ReportStatus.RESOLVED)}
            className={`pb-2 px-4 ${activeTab === ReportStatus.RESOLVED ? "border-b-2 border-blue-600 text-blue-600 font-medium" : "text-gray-500"}`}
          >
            Resolved
          </button>
        </div>

        {loading ? (
          <div className="text-center py-10">Loading...</div>
        ) : (
          <div className="grid gap-4">
            {reports.map((report) => (
              <div key={report.id} className="bg-white p-4 rounded-lg shadow border flex justify-between items-start">
                <div className="space-y-2">
                  <div className="flex items-center space-x-2">
                    <span className={`px-2 py-0.5 rounded text-xs font-bold ${report.itemType === ReportedItemType.QUESTION ? "bg-purple-100 text-purple-700" : "bg-green-100 text-green-700"}`}>
                      {report.itemType} #{report.itemId}
                    </span>
                    <span className="text-gray-400 text-xs">{new Date(report.createdAt).toLocaleString()}</span>
                  </div>
                  <p className="font-medium text-gray-800">{report.reason}</p>
                  <div className="flex items-center text-sm text-gray-500">
                    <Mail size={14} className="mr-1" /> Reported by: {report.reporter.fullName} ({report.reporter.email})
                  </div>
                  {report.adminResponse && (
                    <div className="mt-2 bg-blue-50 p-2 rounded text-sm text-blue-800">
                      <strong>Admin Response:</strong> {report.adminResponse}
                    </div>
                  )}
                </div>

                <div className="flex space-x-2">
                  {activeTab !== ReportStatus.RESOLVED && (
                    <>
                      <button
                        onClick={() => handleOpenResolve(report)}
                        className="p-2 text-green-600 hover:bg-green-50 rounded"
                        title="Resolve"
                      >
                        <CheckCircle size={20} />
                      </button>
                      {activeTab === ReportStatus.NEW && (
                        <button
                          onClick={() => handleDismiss(report.id)}
                          className="p-2 text-red-600 hover:bg-red-50 rounded"
                          title="Mark as Spam"
                        >
                          <Trash2 size={20} />
                        </button>
                      )}
                    </>
                  )}
                </div>
              </div>
            ))}
            {reports.length === 0 && <div className="text-center text-gray-500 py-10">No reports found in this category.</div>}
          </div>
        )}

        {isResolveModalOpen && selectedReport && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center p-4 z-50">
            <div className="bg-white rounded-lg w-full max-w-md p-6">
              <h2 className="text-xl font-bold mb-4">Resolve Report</h2>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Admin Response to User</label>
                  <textarea
                    value={adminResponse}
                    onChange={(e) => setAdminResponse(e.target.value)}
                    className="w-full border p-2 rounded h-24"
                    placeholder="Tell the user what action was taken..."
                  />
                </div>
                <div className="flex items-center space-x-2">
                  <input
                    type="checkbox"
                    id="disableContent"
                    checked={disableContent}
                    onChange={(e) => setDisableContent(e.target.checked)}
                  />
                  <label htmlFor="disableContent" className="text-sm font-medium text-red-600">
                    Disable this {selectedReport.itemType.toLowerCase()} immediately
                  </label>
                </div>
                <div className="flex justify-end space-x-2 pt-4">
                  <button
                    onClick={() => setIsResolveModalOpen(false)}
                    className="px-4 py-2 border rounded text-gray-600 hover:bg-gray-100"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={handleResolveSubmit}
                    disabled={!adminResponse}
                    className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
                  >
                    Submit Resolution
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
};

export default ModerationDashboard;
