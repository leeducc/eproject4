import React, { useEffect, useState } from "react";
import { AdminLayout } from "../../components/AdminLayout";
import { getAppSections, createAppSection, updateAppSection, deleteAppSection, getTags, AppScreenSection, AppScreenSectionRequest, Tag } from "@english-learning/api";
import { X, Search } from "lucide-react";

export const AppManagementPage: React.FC = () => {
  const [sections, setSections] = useState<AppScreenSection[]>([]);
  const [allTags, setAllTags] = useState<Tag[]>([]);
  const [selectedSection, setSelectedSection] = useState<AppScreenSection | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [tagSearch, setTagSearch] = useState("");
  const [formData, setFormData] = useState<AppScreenSectionRequest>({
    skill: "LISTENING",
    sectionName: "",
    difficultyBand: "0-4.0",
    displayOrder: 1,
    tagIds: [],
    guideContent: "",
  });

  const fetchData = async () => {
    try {
      const [sectionsData, tagsData] = await Promise.all([
        getAppSections(),
        getTags()
      ]);
      setSections(sectionsData);
      setAllTags(tagsData);
    } catch (e) {
      console.error(e);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleOpenModal = (section?: AppScreenSection) => {
    setTagSearch("");
    if (section) {
      setSelectedSection(section);
      setFormData({
        skill: section.skill,
        sectionName: section.sectionName,
        difficultyBand: section.difficultyBand,
        displayOrder: section.displayOrder,
        tagIds: section.tags?.map((t) => t.id) || [],
        guideContent: section.guideContent || "",
      });
    } else {
      setSelectedSection(null);
      setFormData({
        skill: "LISTENING",
        sectionName: "",
        difficultyBand: "0-4.0",
        displayOrder: 1,
        tagIds: [],
        guideContent: "",
      });
    }
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setSelectedSection(null);
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleAddTag = (tagId: number) => {
    setFormData(prev => ({
      ...prev,
      tagIds: [...(prev.tagIds || []), tagId]
    }));
    setTagSearch("");
  };

  const handleRemoveTag = (tagId: number) => {
    setFormData(prev => ({
      ...prev,
      tagIds: (prev.tagIds || []).filter(id => id !== tagId)
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (selectedSection) {
        await updateAppSection(selectedSection.id, formData);
      } else {
        await createAppSection(formData);
      }
      fetchData();
      handleCloseModal();
    } catch (e) {
      console.error(e);
      alert("Failed to save section");
    }
  };

  const handleDelete = async (id: number) => {
    if (window.confirm("Are you sure?")) {
      await deleteAppSection(id);
      fetchData();
    }
  };

  const filteredTags = allTags.filter(t => 
    t.name.toLowerCase().includes(tagSearch.toLowerCase()) && 
    !(formData.tagIds || []).includes(t.id)
  );

  return (
    <AdminLayout title="App Management - EnglishHub">
      <div className="p-6">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-2xl font-bold">App Content Configuration</h1>
          <button
            onClick={() => handleOpenModal()}
            className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            + Create Section
          </button>
        </div>

        <table className="w-full text-left bg-white shadow rounded">
          <thead className="bg-gray-50 border-b">
            <tr>
              <th className="p-4">Order</th>
              <th className="p-4">Section Name</th>
              <th className="p-4">Skill</th>
              <th className="p-4">Band</th>
              <th className="p-4">Tags</th>
              <th className="p-4">Actions</th>
            </tr>
          </thead>
          <tbody>
            {sections.map((s) => (
              <tr key={s.id} className="border-b">
                <td className="p-4">{s.displayOrder}</td>
                <td className="p-4">{s.sectionName}</td>
                <td className="p-4">{s.skill}</td>
                <td className="p-4">{s.difficultyBand}</td>
                <td className="p-4">
                  <div className="flex flex-wrap gap-1">
                    {s.tags?.map(t => (
                      <span key={t.id} className="text-xs bg-gray-100 text-gray-700 px-2 py-1 rounded">
                        {t.name}
                      </span>
                    ))}
                    {(!s.tags || s.tags.length === 0) && <span className="text-gray-400 text-sm">No tags</span>}
                  </div>
                </td>
                <td className="p-4 space-x-2">
                  <button className="text-blue-500" onClick={() => handleOpenModal(s)}>Edit</button>
                  <button className="text-red-500" onClick={() => handleDelete(s.id)}>Delete</button>
                </td>
              </tr>
            ))}
            {sections.length === 0 && (
              <tr>
                <td colSpan={6} className="p-4 text-center text-gray-500">No sections found.</td>
              </tr>
            )}
          </tbody>
        </table>

        {isModalOpen && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center p-4 z-50">
            <div className="bg-white rounded-lg w-full max-w-2xl p-6 overflow-y-auto max-h-[90vh]">
              <h2 className="text-xl font-bold mb-4">{selectedSection ? "Edit Section" : "New Section"}</h2>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="flex space-x-4">
                  <div className="flex-1">
                    <label className="block text-sm font-medium">Skill</label>
                    <select name="skill" value={formData.skill} onChange={handleChange} className="w-full border p-2 rounded">
                      <option value="LISTENING">Listening</option>
                      <option value="READING">Reading</option>
                    </select>
                  </div>
                  <div className="flex-1">
                    <label className="block text-sm font-medium">Difficulty Band</label>
                    <select name="difficultyBand" value={formData.difficultyBand} onChange={handleChange} className="w-full border p-2 rounded">
                      <option value="0-4.0">0-4.0</option>
                      <option value="4.5-5.0">4.5-5.0</option>
                      <option value="5.5-6.5">5.5-6.5</option>
                      <option value="7.0-9.0">7.0-9.0</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium">Section Name</label>
                  <input type="text" name="sectionName" value={formData.sectionName} onChange={handleChange} className="w-full border p-2 rounded" required />
                </div>

                <div>
                  <label className="block text-sm font-medium">Display Order</label>
                  <input type="number" name="displayOrder" value={formData.displayOrder} onChange={handleChange} className="w-full border p-2 rounded" required />
                </div>

                <div>
                  <label className="block text-sm font-medium mb-1">Tags mapped to this section</label>
                  <div className="flex flex-wrap gap-2 mb-2 p-2 border rounded min-h-[42px] bg-gray-50">
                    {(formData.tagIds || []).map(id => {
                      const tagInfo = allTags.find(t => t.id === id);
                      if (!tagInfo) return null;
                      return (
                        <div key={id} className="flex items-center bg-blue-100 text-blue-800 px-2 py-1 rounded text-sm">
                          {tagInfo.name}
                          <button type="button" onClick={() => handleRemoveTag(id)} className="ml-1 text-blue-600 hover:text-blue-900">
                            <X size={14} />
                          </button>
                        </div>
                      );
                    })}
                    {(formData.tagIds || []).length === 0 && <span className="text-gray-400 text-sm py-1">No tags selected</span>}
                  </div>
                  
                  <div className="relative">
                    <div className="flex items-center border rounded px-2 bg-white">
                      <Search size={16} className="text-gray-400" />
                      <input 
                        type="text" 
                        value={tagSearch} 
                        onChange={(e) => setTagSearch(e.target.value)} 
                        placeholder="Search and add tags..." 
                        className="w-full p-2 outline-none text-sm" 
                      />
                    </div>
                    {tagSearch && (
                      <div className="absolute z-10 w-full mt-1 bg-white border border-gray-200 rounded-md shadow-lg max-h-48 overflow-auto">
                        {filteredTags.length > 0 ? (
                          filteredTags.map(tag => (
                            <div 
                              key={tag.id} 
                              onClick={() => handleAddTag(tag.id)}
                              className="px-4 py-2 hover:bg-gray-100 cursor-pointer text-sm flex justify-between items-center"
                            >
                              <span>{tag.name}</span>
                              <span className="text-gray-400 text-xs">{tag.namespace}</span>
                            </div>
                          ))
                        ) : (
                          <div className="px-4 py-2 text-sm text-gray-500 text-center">No tags found matching "{tagSearch}"</div>
                        )}
                      </div>
                    )}
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium">Bí kíp làm bài (HTML/Rich Text)</label>
                  <textarea name="guideContent" value={formData.guideContent} onChange={handleChange} className="w-full border p-2 rounded text-sm h-32" placeholder="Write the guide content here... Use <b>...</b>, <p>...</p>, or image tags." />
                </div>

                <div className="flex justify-end space-x-2 pt-4">
                  <button type="button" onClick={handleCloseModal} className="px-4 py-2 border rounded text-gray-600 hover:bg-gray-100">Cancel</button>
                  <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">Save</button>
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
};

export default AppManagementPage;
