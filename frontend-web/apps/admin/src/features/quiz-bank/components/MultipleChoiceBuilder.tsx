import React, { useState } from 'react';
import { useQuizBankStore } from '../store';
import { MultipleChoiceData, DifficultyBand, SkillType, Question } from '../types';
import { 
  Image as ImageIcon, 
  GripVertical, 
  Trash2, 
  Plus,
  X,
  Eye
} from 'lucide-react';
import { toast, ConfirmDialog } from '@english-learning/ui';
import { getMediaUrl } from '../utils';

export interface MultipleChoiceBuilderProps {
  skill?: SkillType;
  initialQuestion?: Question | null;
  onSave?: () => void;
}

export const MultipleChoiceBuilder: React.FC<MultipleChoiceBuilderProps> = ({ skill = 'READING', initialQuestion, onSave }) => {
  const { currentUser, createQuestion, updateQuestion, uploadMedia } = useQuizBankStore();
  
  // Local state for the builder form
  const [difficultyBand, setDifficultyBand] = useState<DifficultyBand>(initialQuestion?.difficultyBand || 'BAND_0_4');
  const [instruction, setInstruction] = useState(initialQuestion?.instruction || '');
  const [explanation, setExplanation] = useState(initialQuestion?.explanation || '');
  const [isPremium, setIsPremium] = useState<boolean>(initialQuestion?.isPremiumContent || false);
  const [previewImageUrl, setPreviewImageUrl] = useState<string | null>(null);
  
  // existing media state
  const existingData = initialQuestion?.data as MultipleChoiceData | undefined;
  const optionImageUrls = existingData?.options?.map(opt => opt.image).filter(Boolean) || [];
  
  const initialMediaItems = (initialQuestion?.mediaUrls || []).map((url, i) => ({
    url,
    type: initialQuestion?.mediaTypes?.[i] || ''
  })).filter(item => !optionImageUrls.includes(item.url));

  const [retainedMedia, setRetainedMedia] = useState<{url: string; type: string}[]>(initialMediaItems);
  
  const [fileToDelete, setFileToDelete] = useState<{ type: 'retained' | 'item', index: number } | null>(null);
  
  
  const [options, setOptions] = useState<{ id: string; label: string }[]>(existingData?.options || [
    { id: '1', label: 'Option 1' },
    { id: '2', label: 'Option 2' },
  ]);
  const [correctIds, setCorrectIds] = useState<string[]>(existingData?.correct_ids || []);
  
  const [isMultipleAnswer, setIsMultipleAnswer] = useState(existingData?.multiple_select || false);
  const [isAnswerWithImage, setIsAnswerWithImage] = useState(existingData?.answer_with_image || false);
  
  // Local state for option-specific images (File for new, string URL for existing)
  const [optionImages, setOptionImages] = useState<Record<string, File | string>>(
    existingData?.options?.reduce((acc, opt) => {
      if (opt.image) acc[opt.id] = opt.image;
      return acc;
    }, {} as Record<string, File | string>) || {}
  );


  const isTeacher = currentUser.role === 'TEACHER';

  const handleAddOption = () => {
    console.log('[MultipleChoiceBuilder] Adding new option');
    const newId = Date.now().toString();
    setOptions([...options, { id: newId, label: `Option ${options.length + 1}` }]);
  };

  const handleRemoveOption = (id: string) => {
    if (isTeacher) return; // Role check
    console.log(`[MultipleChoiceBuilder] Removing option ${id}`);
    setOptions(options.filter(opt => opt.id !== id));
    setCorrectIds(correctIds.filter(cId => cId !== id));
  };

  const handleOptionChange = (id: string, newLabel: string) => {
    setOptions(options.map(opt => opt.id === id ? { ...opt, label: newLabel } : opt));
  };

  const handleOptionImageChange = async (id: string, file: File) => {
    try {
      const url = await uploadMedia(file, 'answers');
      setOptionImages(prev => ({ ...prev, [id]: url }));
    } catch (err) {
      toast.error("Failed to upload image");
    }
  };

  const handleRemoveOptionImage = (id: string) => {
    setOptionImages(prev => {
      const next = { ...prev };
      delete next[id];
      return next;
    });
  };

  const handleToggleCorrect = (id: string) => {
    console.log(`[MultipleChoiceBuilder] Toggling correct status for ${id}`);
    if (isMultipleAnswer) {
      if (correctIds.includes(id)) {
        setCorrectIds(correctIds.filter(cId => cId !== id));
      } else {
        setCorrectIds([...correctIds, id]);
      }
    } else {
      setCorrectIds([id]);
    }
  };

  const handleSave = async () => {
    if (!instruction.trim()) {
      toast.error("Please provide an instruction/question.");
      return;
    }
    if (options.length < 2) {
      toast.error("Please provide at least two options.");
      return;
    }
    if (correctIds.length === 0) {
      toast.error("Please select at least one correct answer.");
      return;
    }
    if (options.some(opt => !opt.label.trim())) {
      toast.error("Please fill in all options.");
      return;
    }

    // Prepare final options
    const finalOptions = options.map(opt => {
      const imageUrl = typeof optionImages[opt.id] === 'string' ? optionImages[opt.id] as string : undefined;
      return {
        ...opt,
        image: imageUrl
      };
    });

    const data: MultipleChoiceData = {
      options: finalOptions,
      correct_ids: correctIds,
      multiple_select: isMultipleAnswer,
      answer_with_image: isAnswerWithImage
    };

    const optionMediaUrls = finalOptions
      .map(opt => opt.image)
      .filter((url): url is string => !!url);

    const payload = {
      skill,
      type: 'MULTIPLE_CHOICE' as const,
      difficultyBand: difficultyBand,
      instruction,
      explanation,
      data,
      isPremiumContent: isPremium,
      retainedMediaUrls: [...retainedMedia.map(m => m.url), ...optionMediaUrls]
    };

    if (initialQuestion) {
      console.log('[MultipleChoiceBuilder] Updating question', { instruction, data });
      await updateQuestion(initialQuestion.id, payload);
    } else {
      console.log('[MultipleChoiceBuilder] Saving question', { instruction, data });
      await createQuestion(payload);
    }
    if (onSave) onSave();
  };

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!e.target.files?.length) return;
    const newFiles = Array.from(e.target.files);
    
    // Constraints check
    const countImages = retainedMedia.filter(m => m.type.startsWith('image/')).length + 
                        newFiles.filter(f => f.type.startsWith('image/')).length;
                        
    const countAV = retainedMedia.filter(m => !m.type.startsWith('image/')).length + 
                    newFiles.filter(f => !f.type.startsWith('image/')).length;

    if (countImages > 0 && countAV > 0) {
      toast.error("Cannot mix images with audio/video files.");
      e.target.value = '';
      return;
    }
    if (countAV > 1) {
      toast.error("Only 1 audio or video file is allowed.");
      e.target.value = '';
      return;
    }
    if (countImages > 3) {
      toast.error("Maximum 3 images allowed.");
      e.target.value = '';
      return;
    }

    try {
      for (const file of newFiles) {
        const url = await uploadMedia(file, 'questions');
        setRetainedMedia(prev => [...prev, { url, type: file.type }]);
      }
      toast.success("Files uploaded successfully");
    } catch (err) {
      toast.error("Failed to upload some files");
    }
    e.target.value = '';
  };

  const handleConfirmDeleteFile = () => {
    if (!fileToDelete) return;
    
    if (fileToDelete.type === 'retained') {
      setRetainedMedia(prev => prev.filter((_, i) => i !== fileToDelete.index));
    } else if (fileToDelete.type === 'item') {
      handleRemoveOptionImage(options[fileToDelete.index].id);
    }
    setFileToDelete(null);
    toast.success("File removed");
  };

  const removeRetainedMedia = (index: number) => {
    setFileToDelete({ type: 'retained', index });
  };


  return (
    <div className="bg-white border rounded-lg shadow-sm w-full max-w-4xl mx-auto p-0 overflow-hidden font-sans">
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
            id="premium-mc"
            checked={isPremium}
            onChange={(e) => setIsPremium(e.target.checked)}
            className="w-4 h-4 text-amber-500 rounded border-gray-300 focus:ring-amber-500"
          />
          <label htmlFor="premium-mc" className="text-sm font-medium text-gray-700 flex items-center gap-1">Premium Content</label>
        </div>
      </div>

      {/* Main Content */}
      <div className="p-6 space-y-6">
        {/* Question Input */}
        <div className="space-y-2">
          <div className="border rounded-md focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500 bg-white">
            <textarea
              className="w-full p-4 border-none focus:ring-0 resize-none min-h-[100px] outline-none"
              placeholder="Type your question here..."
              value={instruction}
              onChange={(e) => setInstruction(e.target.value)}
            />
            <div className="flex flex-col gap-2 p-3 px-4 border-t bg-gray-50 text-gray-500">
              <div className="flex items-center gap-2">
                <span className="text-sm font-semibold text-gray-700 whitespace-nowrap">Attach Media for Question (Max 3 Images OR 1 Video/Audio):</span>
                <input 
                  type="file" 
                  accept="image/*,video/*,audio/*"
                  multiple
                  onChange={handleFileChange}
                  className="text-sm text-gray-600 file:mr-4 file:py-1 file:px-3 file:rounded-md file:border-0 file:text-sm file:font-medium file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
                />
              </div>

                    {/* Retained Media previews (includes newly uploaded) */}
                    {retainedMedia.map((media, idx) => (
                      <div key={`retained-${idx}`} className="flex items-center gap-2 bg-blue-50 border border-blue-200 rounded-md px-2 py-1 pr-1">
                        {media.type?.startsWith('image/') ? (
                          <button 
                            onClick={() => setPreviewImageUrl(getMediaUrl(media.url))}
                            className="text-[10px] font-bold text-blue-600 hover:text-blue-800 flex items-center gap-1 uppercase tracking-tighter"
                          >
                            <Eye size={12} /> View file
                          </button>
                        ) : media.type?.startsWith('video/') ? (
                          <span className="text-[10px] font-bold text-blue-600 flex items-center gap-1 uppercase tracking-tighter cursor-default">
                             Video
                          </span>
                        ) : media.type?.startsWith('audio/') ? (
                          <span className="text-[10px] font-bold text-blue-600 flex items-center gap-1 uppercase tracking-tighter cursor-default">
                             Audio
                          </span>
                        ) : (
                          <a href={getMediaUrl(media.url)} target="_blank" rel="noreferrer" className="text-[10px] font-bold text-blue-600 hover:text-blue-800 flex items-center gap-1 uppercase tracking-tighter">
                            View File
                          </a>
                        )}
                        <button 
                          onClick={() => removeRetainedMedia(idx)}
                          className="text-red-500 hover:bg-red-50 rounded p-0.5 transition-colors"
                          title="Remove attachment"
                        >
                          <X size={14} />
                        </button>
                      </div>
                    ))}
            </div>
          </div>
        </div>

        {/* Settings Row */}
        <div className="flex items-center gap-6">
          <label className="flex items-center gap-2 text-sm text-gray-700 cursor-pointer">
            <div className="relative inline-block w-10 mr-2 align-middle select-none transition duration-200 ease-in">
              <input 
                type="checkbox" 
                name="toggle" 
                checked={isMultipleAnswer}
                onChange={(e) => {
                  setIsMultipleAnswer(e.target.checked);
                  setCorrectIds([]); // Reset on type change
                }}
                className={`toggle-checkbox absolute block w-5 h-5 rounded-full bg-white border-4 appearance-none cursor-pointer transition-transform duration-200 ${isMultipleAnswer ? 'translate-x-5 border-blue-500' : 'translate-x-0 border-gray-300'}`}
              />
              <label className={`toggle-label block overflow-hidden h-5 rounded-full bg-gray-300 cursor-pointer ${isMultipleAnswer ? 'bg-blue-500' : ''}`}></label>
            </div>
            Multiple answer
          </label>
          
          <label className="flex items-center gap-2 text-sm text-gray-700 cursor-pointer">
            <div className="relative inline-block w-10 mr-2 align-middle select-none transition duration-200 ease-in">
              <input 
                type="checkbox" 
                name="toggleImage" 
                checked={isAnswerWithImage}
                onChange={(e) => setIsAnswerWithImage(e.target.checked)}
                className={`toggle-checkbox absolute block w-5 h-5 rounded-full bg-white border-4 appearance-none cursor-pointer transition-transform duration-200 ${isAnswerWithImage ? 'translate-x-5 border-blue-500' : 'translate-x-0 border-gray-300'}`}
              />
              <label className={`toggle-label block overflow-hidden h-5 rounded-full bg-gray-300 cursor-pointer ${isAnswerWithImage ? 'bg-blue-500' : ''}`}></label>
            </div>
            Answer with image
          </label>
        </div>

        {/* Options List */}
        <div className="space-y-3">
          {options.map((opt, index) => (
            <div key={opt.id} className="flex items-center gap-3 group">
              <div 
                className="cursor-pointer flex items-center justify-center w-6 h-6 shrink-0"
                onClick={() => handleToggleCorrect(opt.id)}
              >
                <div className={`w-5 h-5 flex items-center justify-center border ${isMultipleAnswer ? 'rounded' : 'rounded-full'} ${correctIds.includes(opt.id) ? 'bg-green-500 border-green-500' : 'border-gray-300 bg-white hover:border-green-400'}`}>
                   {correctIds.includes(opt.id) && <div className={`${isMultipleAnswer ? 'w-3 h-3 bg-white' : 'w-2.5 h-2.5 bg-white rounded-full'}`}></div>}
                </div>
              </div>
              
              <div className="flex-1 flex items-center border rounded-md px-3 py-2 focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500 bg-white">
                 <span className="text-gray-400 mr-2 font-medium">{String.fromCharCode(65 + index)}.</span>
                 <input 
                   type="text"
                   className="flex-1 outline-none text-gray-700 bg-transparent"
                   value={opt.label}
                   onChange={(e) => handleOptionChange(opt.id, e.target.value)}
                   placeholder="Type an exact answer..."
                 />
                   {isAnswerWithImage && (
                    <div className="flex items-center gap-2 ml-2">
                       {optionImages[opt.id] ? (
                         <div className="flex items-center gap-2 bg-blue-50 border border-blue-200 rounded-md px-2 py-1 pr-1">
                            <button
                              onClick={() => {
                                const img = optionImages[opt.id];
                                if (typeof img === 'string') {
                                  setPreviewImageUrl(getMediaUrl(img));
                                } else {
                                  setPreviewImageUrl(URL.createObjectURL(img));
                                }
                              }}
                              className="text-[10px] font-bold text-blue-600 hover:text-blue-800 flex items-center gap-1 uppercase tracking-tighter"
                            >
                              <Eye size={12} /> View file
                            </button>
                            <button 
                              onClick={() => handleRemoveOptionImage(opt.id)}
                              className="text-red-500 hover:bg-red-50 rounded p-0.5 transition-colors"
                              title="Remove image"
                            >
                              <X size={14} />
                            </button>
                         </div>
                       ) : (
                         <label className="text-gray-400 hover:text-blue-600 cursor-pointer">
                           <ImageIcon size={18} />
                           <input 
                             type="file" 
                             accept="image/*" 
                             className="hidden" 
                             onChange={(e) => {
                               console.log(`[MultipleChoiceBuilder] Image selected for option ${opt.id}`);
                               e.target.files?.[0] && handleOptionImageChange(opt.id, e.target.files[0]);
                             }}
                           />
                         </label>
                       )}
                    </div>
                  )}
              </div>

              <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                <button className="p-1 text-gray-400 hover:text-gray-600 cursor-grab">
                  <GripVertical size={20} />
                </button>
                {!isTeacher && (
                  <button 
                    className="p-1 text-gray-400 hover:text-red-500"
                    onClick={() => handleRemoveOption(opt.id)}
                    title="Delete option"
                  >
                    <Trash2 size={20} />
                  </button>
                )}
              </div>
            </div>
          ))}
          
          <button 
            onClick={handleAddOption}
            className="flex items-center gap-2 text-blue-600 hover:text-blue-700 text-sm font-medium mt-4 disabled:opacity-50"
          >
            <Plus size={16} /> Add answers
          </button>
        </div>

        {/* Explanation Input */}
        <div className="space-y-2 pt-4 border-t border-dashed">
          <label className="text-sm font-semibold text-gray-800">Explanation (Optional)</label>
          <div className="border rounded-md focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500 bg-white">
            <textarea
              className="w-full p-4 border-none focus:ring-0 resize-none min-h-[80px] outline-none"
              placeholder="Provide an explanation for the correct answer..."
              value={explanation}
              onChange={(e) => setExplanation(e.target.value)}
            />
          </div>
        </div>
      </div>

      {/* Footer Settings */}
      <div className="bg-gray-50 p-4 border-t flex items-center justify-end">
        <div>
           <button 
             onClick={handleSave}
             className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
           >
             Save Question
           </button>
        </div>
      </div>

       <ConfirmDialog
        isOpen={fileToDelete !== null}
        onClose={() => setFileToDelete(null)}
        onConfirm={handleConfirmDeleteFile}
        title="Remove Attachment"
        message="Are you sure you want to remove this attached file?"
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
              onLoad={() => {
                if (previewImageUrl.startsWith('blob:')) {
                  // Keep it for now, logic to revoke would go here if we didn't need it multiple times
                }
              }}
            />
          </div>
        </div>
      )}
    </div>
  );
};
