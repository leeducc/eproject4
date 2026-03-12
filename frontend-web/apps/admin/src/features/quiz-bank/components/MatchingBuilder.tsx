import React, { useState } from 'react';
import { useQuizBankStore } from '../store';
import { MatchingData, DifficultyBand, SkillType, Question } from '../types';
import { 
  Plus, Trash2, X, Image as ImageIcon, GripVertical, Eye
} from 'lucide-react';
import { toast, ConfirmDialog } from '@english-learning/ui';
import { getMediaUrl } from '../utils';

export interface MatchingBuilderProps {
  skill?: SkillType;
  initialQuestion?: Question | null;
  onSave?: () => void;
}

export const MatchingBuilder: React.FC<MatchingBuilderProps> = ({ skill = 'READING', initialQuestion, onSave }) => {
  const { currentUser, createQuestion, updateQuestion, uploadMedia } = useQuizBankStore();
  
  // Local state for the form
  const [difficultyBand, setDifficultyBand] = useState<DifficultyBand>(initialQuestion?.difficultyBand || 'BAND_5_6');
  const [instruction, setInstruction] = useState(initialQuestion?.instruction || 'Match the following items.');
  const [explanation, setExplanation] = useState(initialQuestion?.explanation || '');
  const [isPremium, setIsPremium] = useState<boolean>(initialQuestion?.isPremiumContent || false);
  const [previewImageUrl, setPreviewImageUrl] = useState<string | null>(null);
  
  const existingData = initialQuestion?.data as MatchingData | undefined;

  // Local state for item-specific images
  const initialItemImagesObj: Record<string, File | string> = {};
  if (existingData) {
    existingData.left_items.forEach((item, idx) => { if (item.image) initialItemImagesObj[`left-${idx}`] = item.image; });
    existingData.right_items.forEach((item, idx) => { if (item.image) initialItemImagesObj[`right-${idx}`] = item.image; });
  }

  const [itemImages, setItemImages] = useState<Record<string, File | string>>(initialItemImagesObj);

  const initialMediaItems = (initialQuestion?.mediaUrls || []).map((url, i) => ({
    url,
    type: initialQuestion?.mediaTypes?.[i] || ''
  })).filter(item => !Object.values(initialItemImagesObj).some(img => typeof img === 'string' && img === item.url));

  const [retainedMedia, setRetainedMedia] = useState<{url: string; type: string}[]>(initialMediaItems);
  
  const [fileToDelete, setFileToDelete] = useState<{ type: 'retained' | 'item', side?: 'left' | 'right', index: number } | null>(null);
  
  const [pairs, setPairs] = useState<{left: string, right: string}[]>(() => {
    if (!existingData) return [{ left: '', right: '' }];
    return existingData.left_items.map((left) => ({
      left: left.text,
      right: existingData.right_items.find(r => r.id === existingData.solution[left.id])?.text || ''
    }));
  });
  
  const isTeacher = currentUser.role === 'TEACHER';

  const handleAddPair = () => {
    setPairs([...pairs, { left: '', right: '' }]);
  };

  const handleRemovePair = (index: number) => {
    if (isTeacher) return;
    const newPairs = pairs.filter((_, i) => i !== index);
    setPairs(newPairs);
    
    setItemImages(prev => {
      const next = { ...prev };
      delete next[`left-${index}`];
      delete next[`right-${index}`];
      
      const newImages: Record<string, File | string> = {};
      Object.entries(next).forEach(([key, value]) => {
        const [side, oldIdxStr] = key.split('-');
        const oldIdx = parseInt(oldIdxStr);
        if (oldIdx > index) {
          newImages[`${side}-${oldIdx - 1}`] = value;
        } else {
          newImages[key] = value;
        }
      });
      return newImages;
    });
  };

  const handleUpdatePair = (index: number, side: 'left' | 'right', val: string) => {
    const newPairs = [...pairs];
    newPairs[index][side] = val;
    setPairs(newPairs);
  };

  const handleItemImageChange = async (index: number, side: 'left' | 'right', file: File) => {
    try {
      const url = await uploadMedia(file, 'answers');
      setItemImages(prev => ({ ...prev, [`${side}-${index}`]: url }));
    } catch (err) {
      toast.error("Failed to upload image");
    }
  };

  const handleRemoveItemImage = (index: number, side: 'left' | 'right') => {
    setItemImages(prev => {
      const next = { ...prev };
      delete next[`${side}-${index}`];
      return next;
    });
  };

  const handleSave = async () => {
    if (!instruction.trim()) {
      toast.error("Please provide an instruction.");
      return;
    }
    if (pairs.length < 2) {
      toast.error("Please provide at least two matching pairs.");
      return;
    }
    if (pairs.some((p, i) => !p.left.trim() && !itemImages[`left-${i}`])) {
      toast.error("Please fill in text or attach an image for all left items.");
      return;
    }
    if (pairs.some((p, i) => !p.right.trim() && !itemImages[`right-${i}`])) {
      toast.error("Please fill in text or attach an image for all right items.");
      return;
    }

    const left_items = pairs.map((p, i) => {
      const imageUrl = typeof itemImages[`left-${i}`] === 'string' ? itemImages[`left-${i}`] as string : undefined;
      return {
        id: `L${i}`,
        text: p.left,
        image: imageUrl
      };
    });
    
    const right_items = pairs.map((p, i) => {
      const imageUrl = typeof itemImages[`right-${i}`] === 'string' ? itemImages[`right-${i}`] as string : undefined;
      return {
        id: `R${i}`,
        text: p.right,
        image: imageUrl
      };
    });

    const solution: Record<string, string> = {};
    left_items.forEach((item, i) => {
      solution[item.id] = right_items[i].id;
    });

    const data: MatchingData = {
      left_items,
      right_items,
      solution
    };
    
    const itemMediaUrls = [...left_items, ...right_items]
      .map(item => item.image)
      .filter((url): url is string => !!url);

    const payload = {
      skill,
      type: 'MATCHING' as const,
      difficultyBand,
      instruction,
      explanation,
      data,
      isPremiumContent: isPremium,
      retainedMediaUrls: [...retainedMedia.map(m => m.url), ...itemMediaUrls]
    };
    
    if (initialQuestion) {
      await updateQuestion(initialQuestion.id, payload);
    } else {
      await createQuestion(payload);
    }
    if (onSave) onSave();
  };

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!e.target.files?.length) return;
    const newFiles = Array.from(e.target.files);
    
    try {
      for (const file of newFiles) {
        const url = await uploadMedia(file, 'questions');
        setRetainedMedia(prev => [...prev, { url, type: file.type }]);
      }
      toast.success("Files uploaded successfully");
    } catch (err) {
      toast.error("Failed to upload files");
    }
    e.target.value = ''; 
  };

  const handleConfirmDeleteFile = () => {
    if (!fileToDelete) return;
    
    if (fileToDelete.type === 'retained') {
      setRetainedMedia(prev => prev.filter((_, i) => i !== fileToDelete.index));
    } else if (fileToDelete.type === 'item' && fileToDelete.side) {
      handleRemoveItemImage(fileToDelete.index, fileToDelete.side);
    }
    setFileToDelete(null);
    toast.success("File removed");
  };

  return (
    <div className="bg-white border rounded-lg shadow-sm w-full max-w-4xl mx-auto p-0 overflow-hidden font-sans mt-8">
      {/* Header */}
      <div className="flex items-center p-4 border-b bg-gray-50">
        <select 
          className="border-gray-300 rounded-md shadow-sm border p-2 text-sm bg-white"
          value={difficultyBand}
          onChange={(e) => setDifficultyBand(e.target.value as DifficultyBand)}
        >
          <option value="BAND_0_4">Level 0-4</option>
          <option value="BAND_5_6">Level 5-6</option>
          <option value="BAND_7_8">Level 7-8</option>
          <option value="BAND_9">Level 9</option>
        </select>
        <div className="ml-auto flex items-center gap-2 border-l pl-4 border-gray-200">
          <input 
            type="checkbox" 
            id="premium-matching"
            checked={isPremium}
            onChange={(e) => setIsPremium(e.target.checked)}
            className="w-4 h-4 text-amber-500 rounded border-gray-300 focus:ring-amber-500"
          />
          <label htmlFor="premium-matching" className="text-sm font-medium text-gray-700 flex items-center gap-1">Premium Content</label>
        </div>
      </div>

      {/* Main Content */}
      <div className="p-6 space-y-6">
        {/* Question Input */}
        <div className="space-y-2">
          <div className="flex items-center gap-2 text-sm font-bold text-gray-800 bg-gray-100 w-max px-2 py-1 rounded">
             <span className="bg-gray-800 text-white rounded w-4 h-4 flex items-center justify-center text-[10px]">?</span>
             Question
          </div>
          <div className="border rounded-md focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500 bg-gray-50/50 flex flex-col justify-between group">
            <div className="p-2">
               <textarea
                 className="w-full p-2 bg-transparent border-none focus:ring-0 resize-none outline-none font-medium text-gray-800 min-h-[50px]"
                 placeholder="Type your instruction..."
                 value={instruction}
                 onChange={(e) => setInstruction(e.target.value)}
               />
            </div>
            <div className="flex flex-col gap-2 p-3 bg-white border-t text-sm">
              <div className="flex items-center gap-2">
                <span className="font-semibold text-gray-700">Attach Media (Question Level):</span>
                <input 
                  type="file" 
                  accept="image/*,video/*,audio/*"
                  multiple
                  onChange={handleFileChange}
                  className="outline-none"
                />
              </div>
              
              {/* Media Previews */}
              {retainedMedia.length > 0 && (
                <div className="flex flex-wrap gap-4 mt-2">
                  {retainedMedia
                    .map((media, idx) => (
                      <div key={`retained-${idx}`} className="flex items-center gap-2 bg-blue-50 border border-blue-200 rounded-md px-2 py-1 pr-1">
                        {media.type?.startsWith('image/') ? (
                          <button 
                            type="button"
                            onClick={() => setPreviewImageUrl(getMediaUrl(media.url))}
                            className="text-[10px] font-bold text-blue-600 hover:text-blue-800 flex items-center gap-1 uppercase tracking-tighter"
                          >
                            <Eye size={12} /> View file
                          </button>
                        ) : (
                          <span className="text-[10px] font-bold text-blue-400 uppercase tracking-tighter italic">
                             Media File
                          </span>
                        )}
                        <button 
                          onClick={() => setFileToDelete({ type: 'retained', index: idx })}
                          className="text-gray-400 hover:text-red-500 transition-colors"
                        >
                          <Trash2 size={12} />
                        </button>
                      </div>
                    ))}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Pairs List */}
        <div className="space-y-3">
          <div className="flex items-center gap-4 mb-2 pl-8 text-xs font-bold text-gray-400 uppercase tracking-wider">
            <div className="flex-1">Column A (Item)</div>
            <div className="flex-1">Column B (Match)</div>
            {!isTeacher && <div className="w-8"></div>}
          </div>
              
          {pairs.map((pair, index) => (
            <div key={index} className="flex items-center gap-3 group">
              <div className="cursor-grab text-gray-300 group-hover:text-gray-500">
                <GripVertical size={16} />
              </div>
              <div className="w-6 h-6 rounded-full bg-gray-100 border border-gray-200 flex items-center justify-center text-[10px] font-bold text-gray-500">
                 {index + 1}
              </div>
              
              {/* Left Item */}
              <div className="flex-1 border rounded-lg p-2 bg-gray-50 focus-within:bg-white focus-within:ring-1 focus-within:ring-blue-500 transition-all">
                <div className="flex items-center gap-2">
                  <input 
                    className="flex-1 bg-transparent border-none focus:ring-0 text-sm font-medium outline-none"
                    value={pair.left}
                    onChange={(e) => handleUpdatePair(index, 'left', e.target.value)}
                    placeholder="Text..."
                  />
                  <div className="shrink-0 flex items-center">
                    {itemImages[`left-${index}`] ? (
                      <div className="flex items-center gap-1">
                        <button 
                          type="button"
                          onClick={() => {
                            const img = itemImages[`left-${index}`];
                            if (typeof img === 'string') {
                              setPreviewImageUrl(getMediaUrl(img));
                            } else {
                              setPreviewImageUrl(URL.createObjectURL(img));
                            }
                          }}
                          className="bg-blue-50 text-blue-600 border border-blue-200 px-2 py-1 rounded text-[10px] font-bold uppercase tracking-tight flex items-center gap-1 hover:bg-blue-100 transition-colors"
                        >
                          <Eye size={12} /> View
                        </button>
                        <button 
                          type="button"
                          onClick={() => setFileToDelete({ type: 'item', side: 'left', index })}
                          className="text-gray-400 hover:text-red-500 p-1"
                        >
                          <Trash2 size={14} />
                        </button>
                      </div>
                    ) : (
                      <label className="text-gray-400 hover:text-blue-500 cursor-pointer p-1">
                        <ImageIcon size={18} />
                        <input type="file" accept="image/*" className="hidden" onChange={(e) => e.target.files?.[0] && handleItemImageChange(index, 'left', e.target.files[0])} />
                      </label>
                    )}
                  </div>
                </div>
              </div>

              <div className="text-gray-300">→</div>

              {/* Right Item */}
              <div className="flex-1 border rounded-lg p-2 bg-blue-50/30 border-blue-100 focus-within:bg-white focus-within:ring-1 focus-within:ring-blue-500 transition-all">
                <div className="flex items-center gap-2">
                  <input 
                    className="flex-1 bg-transparent border-none focus:ring-0 text-sm font-medium text-blue-900 outline-none"
                    value={pair.right}
                    onChange={(e) => handleUpdatePair(index, 'right', e.target.value)}
                    placeholder="Match..."
                  />
                  <div className="shrink-0 flex items-center">
                    {itemImages[`right-${index}`] ? (
                      <div className="flex items-center gap-1">
                        <button 
                          type="button"
                          onClick={() => {
                            const img = itemImages[`right-${index}`];
                            if (typeof img === 'string') {
                              setPreviewImageUrl(getMediaUrl(img));
                            } else {
                              setPreviewImageUrl(URL.createObjectURL(img));
                            }
                          }}
                          className="bg-white text-blue-600 border border-blue-200 px-2 py-1 rounded text-[10px] font-bold uppercase tracking-tight flex items-center gap-1 hover:bg-blue-100 transition-colors shadow-sm"
                        >
                          <Eye size={12} /> View
                        </button>
                        <button 
                          type="button"
                          onClick={() => setFileToDelete({ type: 'item', side: 'right', index })}
                          className="text-gray-400 hover:text-red-500 p-1"
                        >
                          <Trash2 size={14} />
                        </button>
                      </div>
                    ) : (
                      <label className="text-gray-400 hover:text-blue-500 cursor-pointer p-1">
                        <ImageIcon size={18} />
                        <input type="file" accept="image/*" className="hidden" onChange={(e) => e.target.files?.[0] && handleItemImageChange(index, 'right', e.target.files[0])} />
                      </label>
                    )}
                  </div>
                </div>
              </div>

              {!isTeacher && pairs.length > 1 && (
                <button onClick={() => handleRemovePair(index)} className="p-1.5 text-gray-300 hover:text-red-500 hover:bg-red-50 rounded transition-colors"><Trash2 size={16}/></button>
              )}
            </div>
          ))}
          
          <button 
            onClick={handleAddPair}
            className="flex items-center gap-2 text-sm font-bold text-blue-600 hover:text-blue-700 mt-4 pl-8"
          >
            <Plus size={16} /> Add Matching Pair
          </button>
        </div>

        {/* Explanation */}
        <div className="space-y-2 pt-4 border-t border-dashed">
          <label className="text-sm font-semibold text-gray-800">Explanation (Optional)</label>
          <textarea
            className="w-full p-3 border rounded-md focus:ring-1 focus:ring-blue-500 outline-none min-h-[80px]"
            value={explanation}
            onChange={(e) => setExplanation(e.target.value)}
            placeholder="Why are these matches correct?"
          />
        </div>
      </div>

      <div className="bg-gray-50 p-4 border-t flex justify-end">
        <button onClick={handleSave} className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-md font-bold text-sm shadow-sm transition-all">Save Changes</button>
      </div>

      <ConfirmDialog
        isOpen={fileToDelete !== null}
        onClose={() => setFileToDelete(null)}
        onConfirm={handleConfirmDeleteFile}
        title="Remove File"
        message="Are you sure you want to remove this file?"
        confirmText="Remove"
        variant="danger"
      />

      {/* Full Size Image Preview Modal */}
      {previewImageUrl && (
        <div 
          className="fixed inset-0 z-[9999] flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-in fade-in duration-200"
          onClick={() => setPreviewImageUrl(null)}
        >
          <div className="relative max-w-4xl max-h-[90vh] bg-white rounded-lg p-2 shadow-2xl scale-in" onClick={(e) => e.stopPropagation()}>
            <button 
              onClick={() => setPreviewImageUrl(null)}
              className="absolute -top-4 -right-4 bg-white text-gray-800 rounded-full p-2 shadow-lg hover:bg-gray-100 transition-colors border"
            >
              <X size={20} />
            </button>
            <img 
              src={previewImageUrl} 
              alt="Full Size Preview" 
              className="max-w-full max-h-[85vh] object-contain rounded-sm"
            />
          </div>
        </div>
      )}
    </div>
  );
};
