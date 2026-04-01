import React, { useEffect, useState } from "react";
import { AdminLayout } from "../../components/AdminLayout";
import { 
  getAdminFAQs, 
  createFAQ, 
  updateFAQ, 
  deleteFAQ, 
  FAQ, 
  FAQRequest 
} from "@english-learning/api";
import { Plus, Pencil, Trash2, Save, X, Globe } from "lucide-react";
import ReactQuill from "react-quill";
import "react-quill/dist/quill.snow.css";

type TabType = "EN" | "VI" | "ZH";

export const FAQManagementPage: React.FC = () => {
  const [faqs, setFaqs] = useState<FAQ[]>([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedFaq, setSelectedFaq] = useState<FAQ | null>(null);
  const [activeTab, setActiveTab] = useState<TabType>("EN");
  const [loading, setLoading] = useState(false);

  const [formData, setFormData] = useState<FAQRequest>({
    questionEn: "",
    questionVi: "",
    questionZh: "",
    answerEn: "",
    answerVi: "",
    answerZh: "",
    displayOrder: 1,
    isActive: true,
  });

  const fetchData = async () => {
    setLoading(true);
    try {
      const data = await getAdminFAQs();
      setFaqs(data);
    } catch (e) {
      console.error("Failed to fetch FAQs", e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleOpenModal = (faq?: FAQ) => {
    if (faq) {
      setSelectedFaq(faq);
      setFormData({
        questionEn: faq.questionEn,
        questionVi: faq.questionVi,
        questionZh: faq.questionZh,
        answerEn: faq.answerEn,
        answerVi: faq.answerVi,
        answerZh: faq.answerZh,
        displayOrder: faq.displayOrder,
        isActive: faq.isActive,
      });
    } else {
      setSelectedFaq(null);
      setFormData({
        questionEn: "",
        questionVi: "",
        questionZh: "",
        answerEn: "",
        answerVi: "",
        answerZh: "",
        displayOrder: faqs.length + 1,
        isActive: true,
      });
    }
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setSelectedFaq(null);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (selectedFaq) {
        await updateFAQ(selectedFaq.id, formData);
      } else {
        await createFAQ(formData);
      }
      fetchData();
      handleCloseModal();
    } catch (e) {
      console.error("Failed to save FAQ", e);
      alert("Failed to save FAQ");
    }
  };

  const handleDelete = async (id: number) => {
    if (window.confirm("Are you sure you want to delete this FAQ?")) {
      try {
        await deleteFAQ(id);
        fetchData();
      } catch (e) {
        console.error("Failed to delete FAQ", e);
      }
    }
  };

  const quillModules = {
    toolbar: [
      [{ header: [1, 2, false] }],
      ["bold", "italic", "underline", "strike", "blockquote"],
      [{ list: "ordered" }, { list: "bullet" }],
      ["link", "clean"],
    ],
  };

  return (
    <AdminLayout>
      <div className="p-6">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-2xl font-bold">Frequently Asked Questions</h1>
          <button
            onClick={() => handleOpenModal()}
            className="flex items-center px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition"
          >
            <Plus size={18} className="mr-2" /> New FAQ
          </button>
        </div>

        {loading ? (
          <div className="text-center py-10">Loading...</div>
        ) : (
          <div className="bg-white shadow rounded-lg overflow-hidden">
            <table className="w-full text-left">
              <thead className="bg-gray-50 border-b">
                <tr>
                  <th className="p-4 w-16">Order</th>
                  <th className="p-4">Question (EN)</th>
                  <th className="p-4">Question (VI)</th>
                  <th className="p-4 w-24">Status</th>
                  <th className="p-4 w-32">Actions</th>
                </tr>
              </thead>
              <tbody>
                {faqs.map((faq) => (
                  <tr key={faq.id} className="border-b hover:bg-gray-50">
                    <td className="p-4">{faq.displayOrder}</td>
                    <td className="p-4 font-medium">{faq.questionEn}</td>
                    <td className="p-4 text-gray-600">{faq.questionVi}</td>
                    <td className="p-4">
                      <span className={`px-2 py-1 rounded text-xs ${faq.isActive ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700"}`}>
                        {faq.isActive ? "Active" : "Inactive"}
                      </span>
                    </td>
                    <td className="p-4 space-x-2">
                      <button className="p-1 text-blue-500 hover:text-blue-700" onClick={() => handleOpenModal(faq)}>
                        <Pencil size={18} />
                      </button>
                      <button className="p-1 text-red-500 hover:text-red-700" onClick={() => handleDelete(faq.id)}>
                        <Trash2 size={18} />
                      </button>
                    </td>
                  </tr>
                ))}
                {faqs.length === 0 && (
                  <tr>
                    <td colSpan={5} className="p-10 text-center text-gray-500">No FAQs found.</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        )}

        {isModalOpen && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center p-4 z-50">
            <div className="bg-white rounded-lg w-full max-w-4xl p-6 overflow-y-auto max-h-[90vh] shadow-2xl">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-xl font-bold">{selectedFaq ? "Edit FAQ" : "New FAQ"}</h2>
                <button onClick={handleCloseModal} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>

              <form onSubmit={handleSubmit} className="space-y-6">
                {/* Meta details */}
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-1">Display Order</label>
                    <input
                      type="number"
                      value={formData.displayOrder}
                      onChange={(e) => setFormData({ ...formData, displayOrder: parseInt(e.target.value) })}
                      className="w-full border p-2 rounded focus:ring-2 focus:ring-blue-500 outline-none"
                      required
                    />
                  </div>
                  <div className="flex items-center mt-6">
                    <label className="flex items-center cursor-pointer">
                      <input
                        type="checkbox"
                        checked={formData.isActive}
                        onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                        className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                      />
                      <span className="ml-2 text-sm font-medium">Active</span>
                    </label>
                  </div>
                </div>

                {/* Content Tabs */}
                <div>
                  <div className="flex space-x-1 border-b mb-4">
                    {(["EN", "VI", "ZH"] as TabType[]).map((tab) => (
                      <button
                        key={tab}
                        type="button"
                        onClick={() => setActiveTab(tab)}
                        className={`px-4 py-2 text-sm font-medium transition-colors border-b-2 ${
                          activeTab === tab ? "border-blue-600 text-blue-600" : "border-transparent text-gray-500 hover:text-gray-700"
                        }`}
                      >
                        <span className="flex items-center">
                          <Globe size={14} className="mr-2" /> {tab}
                        </span>
                      </button>
                    ))}
                  </div>

                  <div className="space-y-4">
                    {activeTab === "EN" && (
                      <>
                        <div>
                          <label className="block text-sm font-medium mb-1">Question (English)</label>
                          <input
                            type="text"
                            value={formData.questionEn}
                            onChange={(e) => setFormData({ ...formData, questionEn: e.target.value })}
                            className="w-full border p-2 rounded outline-none focus:ring-2 focus:ring-blue-500"
                            required
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium mb-1">Answer (English)</label>
                          <div className="h-64 mb-12">
                            <ReactQuill
                              theme="snow"
                              value={formData.answerEn}
                              onChange={(val: string) => setFormData({ ...formData, answerEn: val })}
                              modules={quillModules}
                              className="h-48"
                            />
                          </div>
                        </div>
                      </>
                    )}

                    {activeTab === "VI" && (
                      <>
                        <div>
                          <label className="block text-sm font-medium mb-1">Question (Vietnamese)</label>
                          <input
                            type="text"
                            value={formData.questionVi}
                            onChange={(e) => setFormData({ ...formData, questionVi: e.target.value })}
                            className="w-full border p-2 rounded outline-none focus:ring-2 focus:ring-blue-500"
                            required
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium mb-1">Answer (Vietnamese)</label>
                          <div className="h-64 mb-12">
                            <ReactQuill
                              theme="snow"
                              value={formData.answerVi}
                              onChange={(val: string) => setFormData({ ...formData, answerVi: val })}
                              modules={quillModules}
                              className="h-48"
                            />
                          </div>
                        </div>
                      </>
                    )}

                    {activeTab === "ZH" && (
                      <>
                        <div>
                          <label className="block text-sm font-medium mb-1">Question (Chinese)</label>
                          <input
                            type="text"
                            value={formData.questionZh}
                            onChange={(e) => setFormData({ ...formData, questionZh: e.target.value })}
                            className="w-full border p-2 rounded outline-none focus:ring-2 focus:ring-blue-500"
                            required
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium mb-1">Answer (Chinese)</label>
                          <div className="h-64 mb-12">
                            <ReactQuill
                              theme="snow"
                              value={formData.answerZh}
                              onChange={(val: string) => setFormData({ ...formData, answerZh: val })}
                              modules={quillModules}
                              className="h-48"
                            />
                          </div>
                        </div>
                      </>
                    )}
                  </div>
                </div>

                <div className="flex justify-end space-x-3 pt-6 border-t">
                  <button
                    type="button"
                    onClick={handleCloseModal}
                    className="px-4 py-2 border rounded text-gray-600 hover:bg-gray-100 transition"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="flex items-center px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition"
                  >
                    <Save size={18} className="mr-2" /> Save FAQ
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
};

export default FAQManagementPage;
