import React, { useEffect, useState } from "react";
import { AdminLayout } from "../../components/AdminLayout";
import { getReports, resolveReport, dismissReport, getQuestionDetail, getQuestionHistory, getVocabularyDetail, getVocabularyHistory, Report, ReportStatus, ReportedItemType } from "@english-learning/api";
import { CheckCircle, Trash2, Mail, Eye, History, User, Calendar, Hash, X } from "lucide-react";

export const ModerationDashboard: React.FC = () => {
  const [reports, setReports] = useState<Report[]>([]);
  const [activeTab, setActiveTab] = useState<ReportStatus>(ReportStatus.NEW);
  const [selectedReport, setSelectedReport] = useState<Report | null>(null);
  const [isResolveModalOpen, setIsResolveModalOpen] = useState(false);
  const [adminResponse, setAdminResponse] = useState("");
  const [disableContent, setDisableContent] = useState(false);
  const [loading, setLoading] = useState(false);
  const [isDetailModalOpen, setIsDetailModalOpen] = useState(false);
  const [itemDetail, setItemDetail] = useState<any>(null);
  const [itemHistory, setItemHistory] = useState<any[]>([]);
  const [detailLoading, setDetailLoading] = useState(false);

  const fetchReports = async () => {
    setLoading(true);
    try {
      const data = await getReports(activeTab);
      setReports(Array.isArray(data) ? data : []);
    } catch (e) {
      setReports([]);
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

  const handleViewDetail = async (report: Report) => {
    setDetailLoading(true);
    setIsDetailModalOpen(true);
    setItemDetail(null);
    setItemHistory([]);
    try {
      if (report.itemType === ReportedItemType.QUESTION) {
        const [detail, history] = await Promise.all([
          getQuestionDetail(report.itemId),
          getQuestionHistory(report.itemId)
        ]);
        setItemDetail(detail);
        setItemHistory(history);
      } else {
        const [detail, history] = await Promise.all([
          getVocabularyDetail(report.itemId),
          getVocabularyHistory(report.itemId)
        ]);
        setItemDetail(detail);
        setItemHistory(history);
      }
    } catch (e) {
      console.error("Failed to fetch item details:", e);
    } finally {
      setDetailLoading(false);
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
            Spam
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
            {Array.isArray(reports) && reports.map((report) => (
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
                  <button
                    onClick={() => handleViewDetail(report)}
                    className="p-2 text-blue-600 hover:bg-blue-50 rounded"
                    title="View Details"
                  >
                    <Eye size={20} />
                  </button>
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
            {Array.isArray(reports) && reports.length === 0 && <div className="text-center text-gray-500 py-10">No reports found in this category.</div>}
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

        {isDetailModalOpen && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center p-4 z-50">
            <div className="bg-white rounded-xl w-full max-w-4xl max-h-[90vh] overflow-hidden flex flex-col">
              <div className="p-6 border-b flex justify-between items-center bg-gray-50">
                <h2 className="text-xl font-bold flex items-center">
                  <Eye className="mr-2 text-blue-600" />
                  Item Details & History
                </h2>
                <button onClick={() => setIsDetailModalOpen(false)} className="p-2 hover:bg-gray-200 rounded-full">
                  <X size={24} />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto p-6">
                {detailLoading ? (
                  <div className="flex justify-center items-center h-64">
                    <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
                  </div>
                ) : itemDetail ? (
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                    {/* Item Information */}
                    <div className="space-y-6">
                      <section>
                        <h3 className="text-sm font-semibold uppercase tracking-wider text-gray-500 mb-3 flex items-center">
                          <Hash size={16} className="mr-1" /> General Information
                        </h3>
                        <div className="bg-gray-50 p-4 rounded-lg space-y-3">
                          <div className="flex justify-between">
                            <span className="text-gray-600">Type:</span>
                            <span className="font-medium px-2 py-0.5 bg-blue-100 text-blue-700 rounded text-xs">
                              {itemDetail.type || (itemDetail.word ? "VOCABULARY" : "QUESTION")}
                            </span>
                          </div>
                          {itemDetail.skill && (
                            <div className="flex justify-between">
                              <span className="text-gray-600">Skill:</span>
                              <span className="font-medium text-purple-700 uppercase">{itemDetail.skill}</span>
                            </div>
                          )}
                          {itemDetail.difficultyBand && (
                            <div className="flex justify-between">
                              <span className="text-gray-600">Difficulty:</span>
                              <span className="font-medium">{itemDetail.difficultyBand}</span>
                            </div>
                          )}
                          {itemDetail.word && (
                            <div className="flex justify-between">
                              <span className="text-gray-600">Word:</span>
                              <span className="font-bold text-lg text-blue-800">{itemDetail.word}</span>
                            </div>
                          )}
                          {itemDetail.pos && (
                            <div className="flex justify-between">
                              <span className="text-gray-600">POS:</span>
                              <span className="font-medium italic text-gray-700">{itemDetail.pos}</span>
                            </div>
                          )}
                        </div>
                      </section>

                      <section>
                        <h3 className="text-sm font-semibold uppercase tracking-wider text-gray-500 mb-3">Content</h3>
                        <div className="prose prose-sm max-w-none bg-white border border-dashed p-4 rounded-lg">
                          {itemDetail.instruction && (
                            <div className="mb-4">
                              <h4 className="text-xs font-bold text-gray-400 uppercase">Instruction</h4>
                              <p className="text-gray-800">{itemDetail.instruction}</p>
                            </div>
                          )}
                          {itemDetail.explanation && (
                            <div className="mb-4">
                              <h4 className="text-xs font-bold text-gray-400 uppercase">Explanation</h4>
                              <p className="text-gray-700 text-sm italic">{itemDetail.explanation}</p>
                            </div>
                          )}
                          {itemDetail.definition && (
                            <div className="mb-4">
                              <h4 className="text-xs font-bold text-gray-400 uppercase">Definition</h4>
                              <p className="text-gray-800">{itemDetail.definition}</p>
                            </div>
                          )}
                        </div>
                      </section>

                      {itemDetail.mediaUrls && itemDetail.mediaUrls.length > 0 && (
                        <section>
                          <h3 className="text-sm font-semibold uppercase tracking-wider text-gray-500 mb-3">Media Assets</h3>
                          <div className="flex flex-wrap gap-2">
                            {itemDetail.mediaUrls.map((url: string, idx: number) => (
                              <div key={idx} className="border p-2 rounded bg-gray-50 flex items-center space-x-2">
                                {itemDetail.mediaTypes?.[idx]?.includes("audio") ? (
                                  <audio controls src={url} className="h-8 w-48" />
                                ) : (
                                  <a href={url} target="_blank" rel="noreferrer" className="text-blue-600 text-xs hover:underline truncate max-w-[150px]">
                                    {url}
                                  </a>
                                )}
                              </div>
                            ))}
                          </div>
                        </section>
                      )}
                    </div>

                    {/* Change History */}
                    <div className="space-y-6">
                      <h3 className="text-sm font-semibold uppercase tracking-wider text-gray-500 mb-3 flex items-center">
                        <History size={16} className="mr-1" /> Revision History
                      </h3>
                      <div className="space-y-4">
                        {itemHistory.length > 0 ? (
                          itemHistory.map((hist, idx) => (
                            <div key={hist.id || idx} className="relative pl-6 border-l-2 border-gray-100 pb-4">
                              <div className="absolute -left-[9px] top-0 w-4 h-4 rounded-full bg-white border-2 border-blue-400"></div>
                              <div className="bg-white border rounded-lg p-3 shadow-sm hover:shadow-md transition-shadow">
                                <div className="flex justify-between items-center mb-2">
                                  <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded ${
                                    hist.action === "CREATED" ? "bg-green-100 text-green-700" : 
                                    hist.action === "UPDATED" ? "bg-orange-100 text-orange-700" : "bg-blue-100 text-blue-700"
                                  }`}>
                                    {hist.action}
                                  </span>
                                  <span className="text-[10px] text-gray-400 flex items-center">
                                    <Calendar size={10} className="mr-1" />
                                    {new Date(hist.createdAt).toLocaleString()}
                                  </span>
                                </div>
                                <div className="text-xs text-gray-700 flex items-center mb-2">
                                  <User size={12} className="mr-1 text-gray-400" />
                                  Edited by: <span className="font-semibold ml-1">{hist.editorName || "System"}</span>
                                </div>
                                {hist.changes && (
                                  <div className="mt-2 text-[10px] bg-gray-50 p-2 rounded font-mono text-gray-600">
                                    <h5 className="font-bold mb-1 border-b border-gray-200">Changes:</h5>
                                    <pre className="whitespace-pre-wrap">{JSON.stringify(typeof hist.changes === 'string' ? JSON.parse(hist.changes) : hist.changes, null, 2)}</pre>
                                  </div>
                                )}
                              </div>
                            </div>
                          ))
                        ) : (
                          <div className="text-center py-10 text-gray-400 text-sm italic bg-gray-50 rounded-lg">
                            No history records available for this item.
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="text-center py-20 text-gray-500">
                    Failed to load item details. It may have been deleted.
                  </div>
                )}
              </div>

              <div className="p-4 border-t bg-gray-50 flex justify-end">
                <button
                  onClick={() => setIsDetailModalOpen(false)}
                  className="px-6 py-2 bg-gray-800 text-white rounded-lg hover:bg-gray-900 transition-colors shadow-lg shadow-gray-200"
                >
                  Close Detail View
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
};

export default ModerationDashboard;
