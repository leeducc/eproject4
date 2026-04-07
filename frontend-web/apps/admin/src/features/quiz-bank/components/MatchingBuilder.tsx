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
  onSave?: (data: Partial<Question>) => void;
}

export const MatchingBuilder: React.FC<MatchingBuilderProps> = ({ skill = 'READING', initialQuestion, onSave }) => {
  const { currentUser, createQuestion, updateQuestion, uploadMedia } = useQuizBankStore();
  
  
  const [difficultyBand, setDifficultyBand] = useState<DifficultyBand>(initialQuestion?.difficultyBand || 'BAND_5_6');
  const [instruction, setInstruction] = useState(initialQuestion?.instruction || 'Match the following items.');
  const [explanation, setExplanation] = useState(initialQuestion?.explanation || '');
  const [isPremium, setIsPremium] = useState<boolean>(initialQuestion?.isPremiumContent || false);
  const [previewImageUrl, setPreviewImageUrl] = useState<string | null>(null);
  
  const existingData = initialQuestion?.data as MatchingData | undefined;

  
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
    console.log('[MatchingBuilder] Adding new pair');
    setPairs([...pairs, { left: '', right: '' }]);
  };

  const handleRemovePair = (index: number) => {
    if (isTeacher) return;
    console.log(`[MatchingBuilder] Removing pair at index ${index}`);
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
    console.log('[MatchingBuilder] Item image changed', { index, side, fileName: file.name });
    try {
      const url = await uploadMedia(file, 'answers');
      setItemImages(prev => ({ ...prev, [`${side}-${index}`]: url }));
    } catch (err) {
      console.error('[MatchingBuilder] Item image upload failed', err);
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
      retainedMediaUrls: [...retainedMedia.map(m => m.url), ...itemMediaUrls],
      tags: initialQuestion?.tags || []
    };
    
    if (initialQuestion?.id) {
       console.log('[MatchingBuilder] Updating question', { id: initialQuestion.id, payload });
       await updateQuestion(initialQuestion.id, payload);
    } else if (!initialQuestion) {
       console.log('[MatchingBuilder] Creating new question', { payload });
       await createQuestion(payload);
    } else {
       console.log('[MatchingBuilder] Draft state updated');
    }

    if (onSave) onSave(payload);
  };

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!e.target.files?.length) return;
    const newFiles = Array.from(e.target.files);
    
    console.log('[MatchingBuilder] Files selected', { count: newFiles.length });
    try {
      for (const file of newFiles) {
        console.log('[MatchingBuilder] Uploading file', { name: file.name, type: file.type });
        const url = await uploadMedia(file, 'questions');
        setRetainedMedia(prev => [...prev, { url, type: file.type }]);
      }
      toast.success("Files uploaded successfully");
    } catch (err) {
      console.error('[MatchingBuilder] Upload failed', err);
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
    <div className="bg-white dark:bg-slate-900 border dark:border-slate-800 rounded-lg shadow-sm w-full max-w-4xl mx-auto p-0 overflow-hidden font-sans mt-8 transition-colors">
      
      <div className="flex items-center p-4 border-b dark:border-slate-800 bg-gray-50 dark:bg-slate-800/50 transition-colors">
        <select 
          className="border-gray-300 dark:border-slate-700 rounded-md shadow-sm border p-2 text-sm bg-white dark:bg-slate-800 dark:text-slate-100 outline-none focus:ring-1 focus:ring-blue-500"
          value={difficultyBand}
          onChange={(e) => setDifficultyBand(e.target.value as DifficultyBand)}
        >
          <option value="BAND_0_4">Level 0-4</option>
          <option value="BAND_5_6">Level 5-6</option>
          <option value="BAND_7_8">Level 7-8</option>
          <option value="BAND_9">Level 9</option>
        </select>
        <div className="ml-auto flex items-center gap-2 border-l pl-4 border-gray-200 dark:border-slate-800">
          <input 
            type="checkbox" 
            id="premium-matching"
            checked={isPremium}
            onChange={(e) => setIsPremium(e.target.checked)}
            className="w-4 h-4 text-amber-500 rounded border-gray-300 dark:border-slate-700 bg-white dark:bg-slate-800 focus:ring-amber-500"
          />
          <label htmlFor="premium-matching" className="text-sm font-medium text-gray-700 dark:text-slate-300 flex items-center gap-1">Premium Content</label>
        </div>
      </div>

      
      <div className="p-6 space-y-6">
        
        <div className="space-y-2">
          <div className="flex items-center gap-2 text-sm font-bold text-gray-800 dark:text-slate-200 bg-gray-100 dark:bg-slate-800 w-max px-2 py-1 rounded transition-colors">
             <span className="bg-gray-800 dark:bg-slate-700 text-white rounded w-4 h-4 flex items-center justify-center text-[10px]">?</span>
             Question
          </div>
          <div className="border dark:border-slate-800 rounded-md focus-within:ring-1 focus-within:ring-blue-500 dark:focus-within:ring-blue-400 focus-within:border-blue-500 dark:focus-within:border-blue-400 bg-gray-50/50 dark:bg-slate-800/30 flex flex-col justify-between group transition-colors">
            <div className="p-2">
               <textarea
                 className="w-full p-2 bg-transparent border-none focus:ring-0 resize-none outline-none font-medium text-gray-800 dark:text-slate-200 min-h-[50px]"
                 placeholder="Type your instruction..."
                 value={instruction}
                 onChange={(e) => setInstruction(e.target.value)}
               />
            </div>
            <div className="flex flex-col gap-2 p-3 bg-white dark:bg-slate-800/50 border-t dark:border-slate-800 text-sm transition-colors">
              <div className="flex items-center gap-2">
                <span className="font-semibold text-gray-700 dark:text-slate-300">Attach Media (Question Level):</span>
                <input 
                  type="file" 
                  accept="image/*,video/*,audio/*"
                  multiple
                  onChange={handleFileChange}
                  className="hidden"
                  id="matching-question-media"
                />
                <label 
                  htmlFor="matching-question-media"
                  className="cursor-pointer bg-gray-100 dark:bg-slate-800 hover:bg-gray-200 dark:hover:bg-slate-700 text-gray-600 dark:text-slate-300 px-3 py-1.5 rounded-md text-xs font-medium border dark:border-slate-700 transition-colors"
                >
                  Select Media
                </label>
              </div>
              {retainedMedia.length > 0 && (
                <div className="flex flex-wrap gap-4 mt-2">
                  {retainedMedia
                    .map((media, idx) => (
                      <div key={`retained-${idx}`} className="flex items-center gap-2 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-md px-2 py-1 pr-1 transition-colors">
                        {media.type?.startsWith('image/') ? (
                          <button 
                            type="button"
                            onClick={() => setPreviewImageUrl(getMediaUrl(media.url))}
                            className="text-[10px] font-bold text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 flex items-center gap-1 uppercase tracking-tighter"
                          >
                            <Eye size={12} /> View file
                          </button>
                        ) : (
                          <span className="text-[10px] font-bold text-blue-400 dark:text-blue-500 uppercase tracking-tighter italic">
                             Media File
                          </span>
                        )}
                        <button 
                          onClick={() => setFileToDelete({ type: 'retained', index: idx })}
                          className="text-gray-400 dark:text-slate-500 hover:text-red-500 dark:hover:text-red-400 transition-colors"
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

        
        <div className="space-y-3">
          <div className="flex items-center gap-4 mb-2 pl-8 text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider">
            <div className="flex-1">Column A (Item)</div>
            <div className="flex-1">Column B (Match)</div>
            {!isTeacher && <div className="w-8"></div>}
          </div>
              
          {pairs.map((pair, index) => (
            <div key={index} className="flex items-center gap-3 group">
              <div className="cursor-grab text-gray-300 dark:text-slate-700 group-hover:text-gray-500 dark:group-hover:text-slate-500 transition-colors">
                <GripVertical size={16} />
              </div>
              <div className="w-6 h-6 rounded-full bg-gray-100 dark:bg-slate-800 border border-gray-200 dark:border-slate-700 flex items-center justify-center text-[10px] font-bold text-gray-500 dark:text-slate-400 transition-colors">
                 {index + 1}
              </div>
              
              
              <div className="flex-1 border dark:border-slate-800 rounded-lg p-2 bg-gray-50 dark:bg-slate-800/40 focus-within:bg-white dark:focus-within:bg-slate-800 focus-within:ring-1 focus-within:ring-blue-500 dark:focus-within:ring-blue-400 transition-all">
                <div className="flex items-center gap-2">
                  <input 
                    className="flex-1 bg-transparent border-none focus:ring-0 text-sm font-medium outline-none text-gray-700 dark:text-slate-200 placeholder-gray-400 dark:placeholder-slate-500"
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
                          className="bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 border border-blue-200 dark:border-blue-800 px-2 py-1 rounded text-[10px] font-bold uppercase tracking-tight flex items-center gap-1 hover:bg-blue-100 dark:hover:bg-blue-900/50 transition-colors"
                        >
                          <Eye size={12} /> View
                        </button>
                        <button 
                          type="button"
                          onClick={() => setFileToDelete({ type: 'item', side: 'left', index })}
                          className="text-gray-400 dark:text-slate-500 hover:text-red-500 dark:hover:text-red-400 p-1 transition-colors"
                        >
                          <Trash2 size={14} />
                        </button>
                      </div>
                    ) : (
                      <label className="text-gray-400 dark:text-slate-500 hover:text-blue-500 dark:hover:text-blue-400 cursor-pointer p-1 transition-colors">
                        <ImageIcon size={18} />
                        <input 
                          type="file" 
                          className="hidden"
                          accept="image/*"
                          onChange={(e) => {
                            const file = e.target.files?.[0];
                            if (file) handleItemImageChange(index, 'left', file);
                          }}
                        />
                      </label>
                    )}
                  </div>
                </div>
              </div>

              
              <div className="flex-1 border rounded-lg p-2 bg-blue-50/30 dark:bg-blue-900/10 border-blue-100 dark:border-blue-900/30 focus-within:bg-white dark:focus-within:bg-slate-800 focus-within:ring-1 focus-within:ring-blue-500 dark:focus-within:ring-blue-400 transition-all">
                <div className="flex items-center gap-2">
                  <input 
                    className="flex-1 bg-transparent border-none focus:ring-0 text-sm font-medium text-blue-900 dark:text-blue-400 outline-none placeholder-blue-300 dark:placeholder-blue-900/50"
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
                          className="bg-white dark:bg-slate-800 text-blue-600 dark:text-blue-400 border border-blue-200 dark:border-blue-800 px-2 py-1 rounded text-[10px] font-bold uppercase tracking-tight flex items-center gap-1 hover:bg-blue-100 dark:hover:bg-blue-900/50 transition-colors shadow-sm"
                        >
                          <Eye size={12} /> View
                        </button>
                        <button 
                          type="button"
                          onClick={() => setFileToDelete({ type: 'item', side: 'right', index })}
                          className="text-gray-400 dark:text-slate-500 hover:text-red-500 dark:hover:text-red-400 p-1 transition-colors"
                        >
                          <Trash2 size={14} />
                        </button>
                      </div>
                    ) : (
                      <label className="text-gray-400 dark:text-slate-500 hover:text-blue-500 dark:hover:text-blue-400 cursor-pointer p-1 transition-colors">
                        <ImageIcon size={18} />
                        <input 
                          type="file" 
                          className="hidden"
                          accept="image/*"
                          onChange={(e) => {
                            const file = e.target.files?.[0];
                            if (file) handleItemImageChange(index, 'right', file);
                          }}
                        />
                      </label>
                    )}
                  </div>
                </div>
              </div>

              {!isTeacher && (
                <button 
                  onClick={() => handleRemovePair(index)}
                  className="text-gray-400 hover:text-red-500 transition-colors p-1"
                  title="Remove pair"
                >
                  <Trash2 size={16} />
                </button>
              )}
            </div>
          ))}

          {!isTeacher && (
            <button 
              onClick={handleAddPair}
              className="flex items-center gap-2 text-sm font-medium text-blue-600 hover:text-blue-700 mt-2 pl-8 transition-colors"
            >
              <Plus size={16} /> Add Pair
            </button>
          )}
        </div>

        <div className="space-y-2 pt-4 border-t border-dashed dark:border-slate-800 transition-colors">
          <label className="text-sm font-semibold text-gray-800 dark:text-slate-200">Explanation (Optional)</label>
          <textarea
            className="w-full p-3 border dark:border-slate-800 rounded-md bg-white dark:bg-slate-900 text-gray-700 dark:text-slate-200 focus:ring-1 focus:ring-blue-500 dark:focus:ring-blue-400 outline-none min-h-[80px] transition-colors"
            value={explanation}
            onChange={(e) => setExplanation(e.target.value)}
            placeholder="Why are these matches correct?"
          />
        </div>
      </div>

      <div className="bg-gray-50 dark:bg-slate-800/50 p-4 border-t dark:border-slate-800 flex justify-end transition-colors">
        <button onClick={handleSave} className="bg-blue-600 hover:bg-blue-700 dark:bg-blue-600 dark:hover:bg-blue-500 text-white px-6 py-2 rounded-md font-bold text-sm shadow-sm transition-all">Save Changes</button>
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

      {previewImageUrl && (
        <div 
          className="fixed inset-0 z-[9999] flex items-center justify-center bg-black/70 backdrop-blur-md p-4 animate-in fade-in duration-200"
          onClick={() => setPreviewImageUrl(null)}
        >
          <div className="relative max-w-4xl max-h-[90vh] bg-white dark:bg-slate-900 rounded-xl p-2 shadow-2xl scale-in border border-transparent dark:border-slate-800" onClick={(e) => e.stopPropagation()}>
            <button 
              onClick={() => setPreviewImageUrl(null)}
              className="absolute -top-4 -right-4 bg-white dark:bg-slate-800 text-gray-800 dark:text-slate-200 rounded-full p-2 shadow-lg hover:bg-gray-100 dark:hover:bg-slate-700 transition-colors border dark:border-slate-700"
            >
              <X size={20} />
            </button>
            <img 
              src={previewImageUrl} 
              alt="Full Size Preview" 
              className="max-w-full max-h-[85vh] object-contain rounded-lg"
            />
          </div>
        </div>
      )}
    </div>
  );
};
