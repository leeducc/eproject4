import React, { useEffect, useState } from "react";
import { AdminLayout } from "../../components/AdminLayout";
import { getAllPolicies, updatePolicy, Policy } from "@english-learning/api";
import { Save, Globe, Info, ShieldCheck, FileText } from "lucide-react";
import ReactQuill from "react-quill";
import "react-quill/dist/quill.snow.css";
import { toast } from "@english-learning/ui";

type LangTab = "EN" | "VI" | "ZH";
type PolicyType = "TERMS" | "PRIVACY";

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
  });
  const [activeType, setActiveType] = useState<PolicyType>("TERMS");
  const [activeLang, setActiveLang] = useState<LangTab>("EN");
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);

  const fetchData = async () => {
    setLoading(true);
    try {
      const data = await getAllPolicies();
      
      const newMap = { ...policiesMap };
      data.forEach(p => {
        if (p.type === "TERMS" || p.type === "PRIVACY") {
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
    setActiveType(type);
  };

  const updateCurrentPolicy = (updates: Partial<Policy>) => {
    setPoliciesMap(prev => ({
      ...prev,
      [activeType]: { ...prev[activeType], ...updates }
    }));
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
      toast.success(`${activeType === "TERMS" ? "Terms of Service" : "Privacy Policy"} updated successfully`);
    } catch (e) {
      console.error(e);
      toast.error("Failed to update policy");
    } finally {
      setSaving(false);
    }
  };

  const quillModules = {
    toolbar: [
      [{ header: [1, 2, 3, false] }],
      ["bold", "italic", "underline", "strike", "blockquote"],
      [{ list: "ordered" }, { list: "bullet" }],
      ["link", "clean"],
    ],
  };

  const currentPolicy = policiesMap[activeType];

  return (
    <AdminLayout>
      <div className="p-6 max-w-6xl mx-auto">
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-2xl font-bold flex items-center">
              <ShieldCheck className="mr-2 text-blue-600" /> Legal & Policies Management
            </h1>
            <p className="text-gray-500 text-sm mt-1">Manage Terms of Service and Privacy Policy for all supported languages.</p>
          </div>
          <button
            onClick={handleSave}
            disabled={saving || loading}
            className="flex items-center px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition disabled:opacity-50 shadow-md"
          >
            {saving ? "Saving..." : <><Save size={18} className="mr-2" /> Save Changes</>}
          </button>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
          {/* Sidebar / Type Selector */}
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
          </div>

          {/* Editor Area */}
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
                    value={currentPolicy.titleEn || ""}
                    onChange={(e) => updateCurrentPolicy({ titleEn: e.target.value })}
                    className="w-full border p-3 rounded-lg outline-none focus:ring-2 focus:ring-blue-500 mb-6 bg-gray-50 focus:bg-white transition"
                    placeholder="Enter English Title..."
                  />
                  <label className="block text-sm font-semibold mb-2">Content (EN)</label>
                  <div className="h-[500px] mb-12">
                    <ReactQuill
                      theme="snow"
                      value={currentPolicy.contentEn || ""}
                      onChange={(val: string) => updateCurrentPolicy({ contentEn: val })}
                      modules={quillModules}
                      className="h-full"
                    />
                  </div>
                </div>
              )}

              {activeLang === "VI" && (
                <div className="animate-in fade-in duration-300">
                  <label className="block text-sm font-semibold mb-2">Policy Title (VI)</label>
                  <input
                    type="text"
                    value={currentPolicy.titleVi || ""}
                    onChange={(e) => updateCurrentPolicy({ titleVi: e.target.value })}
                    className="w-full border p-3 rounded-lg outline-none focus:ring-2 focus:ring-blue-500 mb-6 bg-gray-50 focus:bg-white transition"
                    placeholder="Nhập tiêu đề tiếng Việt..."
                  />
                  <label className="block text-sm font-semibold mb-2">Content (VI)</label>
                  <div className="h-[500px] mb-12">
                    <ReactQuill
                      theme="snow"
                      value={currentPolicy.contentVi || ""}
                      onChange={(val: string) => updateCurrentPolicy({ contentVi: val })}
                      modules={quillModules}
                      className="h-full"
                    />
                  </div>
                </div>
              )}

              {activeLang === "ZH" && (
                <div className="animate-in fade-in duration-300">
                  <label className="block text-sm font-semibold mb-2">Policy Title (ZH)</label>
                  <input
                    type="text"
                    value={currentPolicy.titleZh || ""}
                    onChange={(e) => updateCurrentPolicy({ titleZh: e.target.value })}
                    className="w-full border p-3 rounded-lg outline-none focus:ring-2 focus:ring-blue-500 mb-6 bg-gray-50 focus:bg-white transition"
                    placeholder="输入中文标题..."
                  />
                  <label className="block text-sm font-semibold mb-2">Content (ZH)</label>
                  <div className="h-[500px] mb-12">
                    <ReactQuill
                      theme="snow"
                      value={currentPolicy.contentZh || ""}
                      onChange={(val: string) => updateCurrentPolicy({ contentZh: val })}
                      modules={quillModules}
                      className="h-full"
                    />
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
};

export default LegalManagementPage;
