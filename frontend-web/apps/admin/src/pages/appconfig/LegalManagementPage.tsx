import React, { useEffect, useState } from "react";
import { AdminLayout } from "../../components/AdminLayout";
import { getAllPolicies, updatePolicy, Policy, createSystemNotification } from "@english-learning/api";
import { Save, Globe, Info, ShieldCheck, FileText, Bell, Send, X, Edit3, History } from "lucide-react";
import ReactQuill from "react-quill";
import "react-quill/dist/quill.snow.css";
import { toast, ConfirmDialog } from "@english-learning/ui";
import { PolicyHistoryModal } from "./components/PolicyHistoryModal";

const QUILL_MODULES = {
  toolbar: [
    [{ header: [1, 2, 3, false] }],
    ["bold", "italic", "underline", "strike", "blockquote"],
    [{ list: "ordered" }, { list: "bullet" }],
    ["link", "clean"],
  ],
};

type LangTab = "EN" | "VI" | "ZH";
type PolicyType = "TERMS" | "PRIVACY" | "DELETE_ACCOUNT";

export const LegalManagementPage: React.FC = () => {
  const [policiesMap, setPoliciesMap] = useState<Record<PolicyType, Partial<Policy>>>({
    TERMS: {
      type: "TERMS",
      titleEn: "Terms of Service",
      titleVi: "Điều khoản Dịch vụ",
      titleZh: "服务条款",
      contentEn: "",
      contentVi: "",
      contentZh: "",
    },
    PRIVACY: {
      type: "PRIVACY",
      titleEn: "Privacy Policy",
      titleVi: "Chính sách Bảo mật",
      titleZh: "隐私政策",
      contentEn: "",
      contentVi: "",
      contentZh: "",
    },
    DELETE_ACCOUNT: {
      type: "DELETE_ACCOUNT",
      titleEn: "Account Deletion Policy",
      titleVi: "Chính sách Xóa tài khoản",
      titleZh: "账户注销政策",
      contentEn: "",
      contentVi: "",
      contentZh: "",
    },
  });
  const [activeType, setActiveType] = useState<PolicyType>("TERMS");
  const [activeLang, setActiveLang] = useState<LangTab>("EN");
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [isConfirmOpen, setIsConfirmOpen] = useState(false);
  const [isComposeOpen, setIsComposeOpen] = useState(false);
  const [notificationMsg, setNotificationMsg] = useState({ title: "", content: "" });
  const [sendingNotification, setSendingNotification] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [backupPoliciesMap, setBackupPoliciesMap] = useState<Record<PolicyType, Partial<Policy>> | null>(null);
  const [pendingType, setPendingType] = useState<PolicyType | null>(null);
  const [isNavConfirmOpen, setIsNavConfirmOpen] = useState(false);
  const [isHistoryOpen, setIsHistoryOpen] = useState(false);

  useEffect(() => {
    console.log("[LegalManagementPage] Component Mounted");
    return () => console.log("[LegalManagementPage] Component UNMOUNTED");
  }, []);

  useEffect(() => {
    console.log("[LegalManagementPage] isEditing changed to:", isEditing);
  }, [isEditing]);

  
  useEffect(() => {
    const handleBeforeUnload = (e: BeforeUnloadEvent) => {
      if (isEditing) {
        console.log("[LegalManagementPage] Blocking browser exit due to isEditing=true");
        e.preventDefault();
        e.returnValue = "You have unsaved changes. Are you sure you want to leave?";
        return e.returnValue;
      }
    };

    window.addEventListener("beforeunload", handleBeforeUnload);
    return () => window.removeEventListener("beforeunload", handleBeforeUnload);
  }, [isEditing]);

  const fetchData = async () => {
    setLoading(true);
    try {
      const data = await getAllPolicies();
      
      const newMap = { ...policiesMap };
      data.forEach(p => {
        if (p.type === "TERMS" || p.type === "PRIVACY" || p.type === "DELETE_ACCOUNT") {
          newMap[p.type as PolicyType] = p;
        }
      });
      setPoliciesMap(newMap);
    } catch (e) {
      console.error(e);
      toast.error("Failed to fetch policies");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleTypeChange = (type: PolicyType) => {
    if (isEditing && type !== activeType) {
      console.log(`[LegalManagementPage] Blocking tab change from ${activeType} to ${type}`);
      setPendingType(type);
      setIsNavConfirmOpen(true);
    } else {
      setActiveType(type);
    }
  };

  const handleConfirmNav = () => {
    console.log("[LegalManagementPage] User confirmed navigation: discarding changes");
    if (pendingType) {
      setActiveType(pendingType);
      setPendingType(null);
    }
    setIsEditing(false);
    setBackupPoliciesMap(null);
    setIsNavConfirmOpen(false);
  };

  const handleCancelNav = () => {
    console.log("[LegalManagementPage] User canceled navigation: staying on current page");
    setPendingType(null);
    setIsNavConfirmOpen(false);
  };

  const updateCurrentPolicy = (updates: Partial<Policy>) => {
    console.log("[LegalManagementPage] Updating policy:", activeType, updates);
    setPoliciesMap(prev => ({
      ...prev,
      [activeType]: { ...prev[activeType], ...updates }
    }));
  };

  const handleEdit = () => {
    console.log("[LegalManagementPage] Entering Edit mode for:", activeType);
    setBackupPoliciesMap(JSON.parse(JSON.stringify(policiesMap))); 
    setIsEditing(true);
  };

  const handleCancel = () => {
    console.log("[LegalManagementPage] Canceling edits: restoring backup");
    if (backupPoliciesMap) {
      setPoliciesMap(backupPoliciesMap);
    }
    setIsEditing(false);
    setBackupPoliciesMap(null);
  };

  const handleSave = async () => {
    setSaving(true);
    const policyToSave = policiesMap[activeType];
    try {
      const updated = await updatePolicy(policyToSave);
      setPoliciesMap(prev => ({
        ...prev,
        [updated.type as PolicyType]: updated
      }));
      
      let policyName = "Policy";
      if (activeType === "TERMS") policyName = "Terms of Service";
      else if (activeType === "PRIVACY") policyName = "Privacy Policy";
      else if (activeType === "DELETE_ACCOUNT") policyName = "Account Deletion Policy";

      toast.success(`${policyName} updated successfully`);
      
      
      setNotificationMsg({
        title: `Policy Update: ${policyName}`,
        content: `<p>We've updated our <strong>${policyName}</strong>. Please take a moment to review the latest changes to stay informed about our updated terms and guidelines.</p>`
      });
      setIsConfirmOpen(true);
    } catch (e) {
      console.error(e);
      toast.error("Failed to update policy");
    } finally {
      setSaving(false);
      setIsEditing(false);
      setBackupPoliciesMap(null);
    }
  };

  const handleSendNotification = async () => {
    setSendingNotification(true);
    try {
      await createSystemNotification({
        title: notificationMsg.title,
        content: notificationMsg.content,
        type: "POLICY_UPDATE"
      });
      toast.success("Users alerted successfully!");
      setIsComposeOpen(false);
    } catch (e) {
      console.error(e);
      toast.error("Failed to send notification");
    } finally {
      setSendingNotification(false);
    }
  };

  const EMPTY_MODULES = { toolbar: false };
  const quillModules = isEditing ? QUILL_MODULES : EMPTY_MODULES;

  const currentPolicy = policiesMap[activeType];
  console.log(`[LegalManagementPage] UI Render: type=${activeType}, isEditing=${isEditing}, hasContent=${!!currentPolicy?.contentEn}, backupSet=${!!backupPoliciesMap}`);

  return (
    <AdminLayout>
      <style>
        {`
          .quill-editing .ql-container {
            min-height: 400px;
          }
          .quill-readonly .ql-container {
            border: none !important;
          }
          .quill-readonly .ql-editor {
            padding: 0 !important;
          }
          .quill-readonly .ql-tooltip {
            display: none !important;
          }
        `}
      </style>
      <div className="p-6 max-w-6xl mx-auto">
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-2xl font-bold flex items-center">
              <ShieldCheck className="mr-2 text-blue-600" /> Legal & Policies Management
            </h1>
            <p className="text-gray-500 text-sm mt-1">Manage Terms of Service and Privacy Policy for all supported languages.</p>
          </div>
          <div className="flex gap-3">
            {isEditing ? (
              <>
                <button
                  onClick={handleCancel}
                  className="flex items-center px-4 py-2 bg-white text-gray-700 border border-gray-200 rounded-lg hover:bg-gray-50 transition shadow-sm font-semibold"
                >
                  <X size={18} className="mr-2" /> Cancel
                </button>
                <button
                  onClick={handleSave}
                  disabled={saving || loading}
                  className="flex items-center px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition disabled:opacity-50 shadow-md font-semibold"
                >
                  {saving ? "Saving..." : <><Save size={18} className="mr-2" /> Save Changes</>}
                </button>
              </>
            ) : (
              <div className="flex gap-2">
                <button
                  onClick={() => setIsHistoryOpen(true)}
                  className="flex items-center px-4 py-2 bg-white text-gray-700 border border-gray-200 rounded-lg hover:bg-gray-50 transition shadow-sm font-semibold text-sm"
                >
                  <History size={18} className="mr-2 text-gray-500" /> Revision History
                </button>
                <button
                  onClick={handleEdit}
                  disabled={loading}
                  className="flex items-center px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition disabled:opacity-50 shadow-md font-semibold text-sm"
                >
                  <Edit3 size={18} className="mr-2" /> Edit Page
                </button>
              </div>
            )}
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
          {}
          <div className="lg:col-span-1 space-y-2">
            <button
              onClick={() => handleTypeChange("TERMS")}
              className={`w-full text-left px-4 py-3 rounded-lg flex items-center transition ${
                activeType === "TERMS" ? "bg-blue-50 text-blue-700 border-l-4 border-blue-600 font-semibold" : "hover:bg-gray-100 text-gray-600"
              }`}
            >
              <FileText size={18} className="mr-3" /> Terms of Service
            </button>
            <button
              onClick={() => handleTypeChange("PRIVACY")}
              className={`w-full text-left px-4 py-3 rounded-lg flex items-center transition ${
                activeType === "PRIVACY" ? "bg-blue-50 text-blue-700 border-l-4 border-blue-600 font-semibold" : "hover:bg-gray-100 text-gray-600"
              }`}
            >
              <Info size={18} className="mr-3" /> Privacy Policy
            </button>
            <button
              onClick={() => handleTypeChange("DELETE_ACCOUNT")}
              className={`w-full text-left px-4 py-3 rounded-lg flex items-center transition ${
                activeType === "DELETE_ACCOUNT" ? "bg-blue-50 text-blue-700 border-l-4 border-blue-600 font-semibold" : "hover:bg-gray-100 text-gray-600"
              }`}
            >
              <ShieldCheck size={18} className="mr-3" /> Delete Policy
            </button>
          </div>

          {}
          <div className="lg:col-span-3 bg-white rounded-xl shadow-sm border p-6">
            <div className="flex space-x-1 border-b mb-6">
              {(["EN", "VI", "ZH"] as LangTab[]).map((lang) => (
                <button
                  key={lang}
                  onClick={() => setActiveLang(lang)}
                  className={`px-6 py-3 text-sm font-medium transition-colors border-b-2 flex items-center ${
                    activeLang === lang ? "border-blue-600 text-blue-600" : "border-transparent text-gray-500 hover:text-gray-700"
                  }`}
                >
                  <Globe size={16} className="mr-2" /> {lang === "EN" ? "English" : lang === "VI" ? "Vietnamese" : "Chinese"}
                </button>
              ))}
            </div>

            <div className="space-y-6">
              {activeLang === "EN" && (
                <div className="animate-in fade-in duration-300">
                  <label className="block text-sm font-semibold mb-2">Policy Title (EN)</label>
                  <input
                    type="text"
                    readOnly={!isEditing}
                    value={currentPolicy.titleEn || ""}
                    onChange={(e) => updateCurrentPolicy({ titleEn: e.target.value })}
                    className={`w-full border p-3 rounded-lg outline-none transition ${
                      isEditing 
                        ? "focus:ring-2 focus:ring-blue-500 bg-gray-50 focus:bg-white border-gray-300" 
                        : "bg-transparent border-transparent cursor-default font-bold text-xl px-0"
                    }`}
                    placeholder={isEditing ? "Enter English Title..." : ""}
                  />
                  <label className="block text-sm font-semibold mb-2">Content (EN)</label>
                  <div className={`mb-12 border rounded-lg bg-white overflow-hidden transition-all ${isEditing ? "min-h-[500px]" : "min-h-[300px]"}`}>
                    <ReactQuill
                      key={`${activeType}-EN-${isEditing}`}
                      theme="snow"
                      readOnly={!isEditing}
                      value={currentPolicy.contentEn || ""}
                      onChange={(val, _delta, source) => {
                        if (isEditing && (source === "user" || (source as any) === "api")) {
                           console.log("[LegalManagementPage] EN Content change:", val.substring(0, 20));
                           updateCurrentPolicy({ contentEn: val });
                        }
                      }}
                      modules={quillModules}
                      className={isEditing ? "quill-editing" : "quill-readonly"}
                    />
                  </div>
                </div>
              )}

              {activeLang === "VI" && (
                <div className="animate-in fade-in duration-300">
                  <label className="block text-sm font-semibold mb-2">Policy Title (VI)</label>
                  <input
                    type="text"
                    readOnly={!isEditing}
                    value={currentPolicy.titleVi || ""}
                    onChange={(e) => updateCurrentPolicy({ titleVi: e.target.value })}
                    className={`w-full border p-3 rounded-lg outline-none transition ${
                      isEditing 
                        ? "focus:ring-2 focus:ring-blue-500 bg-gray-50 focus:bg-white border-gray-300" 
                        : "bg-transparent border-transparent cursor-default font-bold text-xl px-0"
                    }`}
                    placeholder={isEditing ? "Nhập tiêu đề tiếng Việt..." : ""}
                  />
                  <label className="block text-sm font-semibold mb-2">Content (VI)</label>
                  <div className={`mb-12 border rounded-lg bg-white overflow-hidden transition-all ${isEditing ? "min-h-[500px]" : "min-h-[300px]"}`}>
                    <ReactQuill
                      key={`${activeType}-VI-${isEditing}`}
                      theme="snow"
                      readOnly={!isEditing}
                      value={currentPolicy.contentVi || ""}
                      onChange={(val, _delta, source) => {
                        if (isEditing && (source === "user" || (source as any) === "api")) {
                           console.log("[LegalManagementPage] VI Content change:", val.substring(0, 20));
                           updateCurrentPolicy({ contentVi: val });
                        }
                      }}
                      modules={quillModules}
                      className={isEditing ? "quill-editing" : "quill-readonly"}
                    />
                  </div>
                </div>
              )}

              {activeLang === "ZH" && (
                <div className="animate-in fade-in duration-300">
                  <label className="block text-sm font-semibold mb-2">Policy Title (ZH)</label>
                  <input
                    type="text"
                    readOnly={!isEditing}
                    value={currentPolicy.titleZh || ""}
                    onChange={(e) => updateCurrentPolicy({ titleZh: e.target.value })}
                    className={`w-full border p-3 rounded-lg outline-none transition ${
                      isEditing 
                        ? "focus:ring-2 focus:ring-blue-500 bg-gray-50 focus:bg-white border-gray-300" 
                        : "bg-transparent border-transparent cursor-default font-bold text-xl px-0"
                    }`}
                    placeholder={isEditing ? "输入中文标题..." : ""}
                  />
                  <label className="block text-sm font-semibold mb-2">Content (ZH)</label>
                  <div className={`mb-12 border rounded-lg bg-white overflow-hidden transition-all ${isEditing ? "min-h-[500px]" : "min-h-[300px]"}`}>
                    <ReactQuill
                      key={`${activeType}-ZH-${isEditing}`}
                      theme="snow"
                      readOnly={!isEditing}
                      value={currentPolicy.contentZh || ""}
                      onChange={(val, _delta, source) => {
                        if (isEditing && (source === "user" || (source as any) === "api")) {
                           console.log("[LegalManagementPage] ZH Content change:", val.substring(0, 20));
                           updateCurrentPolicy({ contentZh: val });
                        }
                      }}
                      modules={quillModules}
                      className={isEditing ? "quill-editing" : "quill-readonly"}
                    />
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      <ConfirmDialog
        isOpen={isConfirmOpen}
        onClose={() => setIsConfirmOpen(false)}
        onConfirm={() => setIsComposeOpen(true)}
        title="Notify Users?"
        message="Would you like to alert all users about these policy changes via a notification?"
        confirmText="Compose Alert"
        cancelText="Skip"
        variant="info"
      />

      {isComposeOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="bg-white dark:bg-slate-900 rounded-xl shadow-2xl max-w-2xl w-full overflow-hidden animate-in zoom-in-95 duration-200 border dark:border-slate-800 flex flex-col max-h-[90vh]">
            <div className="px-6 py-4 border-b dark:border-slate-800 flex justify-between items-center bg-gray-50 dark:bg-slate-800/50">
              <h3 className="text-xl font-bold flex items-center">
                <Bell className="mr-2 text-blue-600" size={20} /> Compose User Alert
              </h3>
              <button onClick={() => setIsComposeOpen(false)} className="text-gray-400 hover:text-gray-600">
                <X size={20} />
              </button>
            </div>
            
            <div className="p-6 space-y-4 overflow-y-auto flex-1">
              <div>
                <label className="block text-sm font-semibold mb-1 text-gray-700">Notification Title</label>
                <input
                  type="text"
                  value={notificationMsg.title}
                  onChange={(e) => setNotificationMsg(prev => ({ ...prev, title: e.target.value }))}
                  className="w-full border p-2 rounded-lg outline-none focus:ring-2 focus:ring-blue-500 bg-gray-50 focus:bg-white transition text-sm"
                  placeholder="Notification title..."
                />
              </div>
              
              <div className="flex flex-col h-[300px]">
                <label className="block text-sm font-semibold mb-1 text-gray-700">Message Content (HTML/CSS)</label>
                <div className="flex-1 bg-white">
                  <ReactQuill
                    theme="snow"
                    value={notificationMsg.content}
                    onChange={(val) => setNotificationMsg(prev => ({ ...prev, content: val }))}
                    modules={quillModules}
                    className="h-[200px]"
                    placeholder="Enter the alert message for all users..."
                  />
                </div>
              </div>
            </div>

            <div className="p-6 border-t dark:border-slate-800 flex justify-end gap-3 bg-gray-50 dark:bg-slate-800/50">
              <button
                onClick={() => setIsComposeOpen(false)}
                className="px-4 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-100 rounded-lg transition-colors border border-gray-200"
              >
                Cancel
              </button>
              <button
                onClick={handleSendNotification}
                disabled={sendingNotification || !notificationMsg.title || !notificationMsg.content}
                className="flex items-center px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition disabled:opacity-50 shadow-md font-semibold"
              >
                {sendingNotification ? "Sending..." : <><Send size={18} className="mr-2" /> Send to All Users</>}
              </button>
            </div>
          </div>
        </div>
      )}

      {}
      <ConfirmDialog
        isOpen={isNavConfirmOpen}
        onClose={handleCancelNav}
        onConfirm={handleConfirmNav}
        title="Unsaved Changes"
        message="You have unsaved changes in your current edit session. If you switch policy types now, these changes will be permanently discarded. Do you want to proceed?"
        confirmText="Discard & Proceed"
        cancelText="Stay Here"
        variant="warning"
      />

      <PolicyHistoryModal 
        isOpen={isHistoryOpen}
        onClose={() => setIsHistoryOpen(false)}
        type={activeType}
        policyName={activeType === "TERMS" ? "Terms of Service" : activeType === "PRIVACY" ? "Privacy Policy" : "Account Deletion Policy"}
      />
    </AdminLayout>
  );
};

export default LegalManagementPage;
