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
  onSave?: (data: Partial<Question>) => void;
}

export const MultipleChoiceBuilder: React.FC<MultipleChoiceBuilderProps> = ({ skill = 'READING', initialQuestion, onSave }) => {
  const { currentUser, createQuestion, updateQuestion, uploadMedia } = useQuizBankStore();
  
  
  const [difficultyBand, setDifficultyBand] = useState<DifficultyBand>(initialQuestion?.difficultyBand || 'BAND_0_4');
  const [instruction, setInstruction] = useState(initialQuestion?.instruction || '');
  const [explanation, setExplanation] = useState(initialQuestion?.explanation || '');
  const [isPremium, setIsPremium] = useState<boolean>(initialQuestion?.isPremiumContent || false);
  const [previewImageUrl, setPreviewImageUrl] = useState<string | null>(null);
  
  
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
    if (isTeacher) return; 
    console.log(`[MultipleChoiceBuilder] Removing option ${id}`);
    setOptions(options.filter(opt => opt.id !== id));
    setCorrectIds(correctIds.filter(cId => cId !== id));
  };

  const handleOptionChange = (id: string, newLabel: string) => {
    setOptions(options.map(opt => opt.id === id ? { ...opt, label: newLabel } : opt));
  };

  const handleOptionImageChange = async (id: string, file: File) => {
    console.log('[MultipleChoiceBuilder] Option image changed', { id, fileName: file.name });
    try {
      const url = await uploadMedia(file, 'answers');
      setOptionImages(prev => ({ ...prev, [id]: url }));
    } catch (err) {
      console.error('[MultipleChoiceBuilder] Option image upload failed', err);
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
      retainedMediaUrls: [...retainedMedia.map(m => m.url), ...optionMediaUrls],
      tags: initialQuestion?.tags || []
    };

    if (initialQuestion?.id) {
      console.log('[MultipleChoiceBuilder] Updating question', { id: initialQuestion.id, payload });
      await updateQuestion(initialQuestion.id, payload);
    } else if (!initialQuestion) {
      console.log('[MultipleChoiceBuilder] Creating new question', { payload });
      await createQuestion(payload);
    } else {
      console.log('[MultipleChoiceBuilder] Draft state updated');
    }

    if (onSave) onSave(payload);
  };

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!e.target.files?.length) return;
    const newFiles = Array.from(e.target.files);
    
    
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

    console.log('[MultipleChoiceBuilder] Files selected', { count: newFiles.length });
    try {
      for (const file of newFiles) {
        console.log('[MultipleChoiceBuilder] Uploading file', { name: file.name, type: file.type });
        const url = await uploadMedia(file, 'questions');
        setRetainedMedia(prev => [...prev, { url, type: file.type }]);
      }
      toast.success("Files uploaded successfully");
    } catch (err) {
      console.error('[MultipleChoiceBuilder] Upload failed', err);
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
    <div className="bg-white dark:bg-slate-900 border dark:border-slate-800 rounded-lg shadow-sm w-full max-w-4xl mx-auto p-0 overflow-hidden font-sans transition-colors">
      
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
            id="premium-mc"
            checked={isPremium}
            onChange={(e) => setIsPremium(e.target.checked)}
            className="w-4 h-4 text-amber-500 rounded border-gray-300 dark:border-slate-700 bg-white dark:bg-slate-800 focus:ring-amber-500"
          />
          <label htmlFor="premium-mc" className="text-sm font-medium text-gray-700 dark:text-slate-300 flex items-center gap-1">Premium Content</label>
        </div>
      </div>

      
      <div className="p-6 space-y-6">
        
        <div className="space-y-2">
          <div className="border dark:border-slate-800 rounded-md focus-within:ring-1 focus-within:ring-blue-500 dark:focus-within:ring-blue-400 focus-within:border-blue-500 dark:focus-within:border-blue-400 bg-white dark:bg-slate-800 transition-colors">
            <textarea
              className="w-full p-4 border-none focus:ring-0 bg-transparent text-gray-700 dark:text-slate-200 resize-none min-h-[100px] outline-none"
              placeholder="Type your question here..."
              value={instruction}
              onChange={(e) => setInstruction(e.target.value)}
            />
            <div className="flex flex-col gap-2 p-3 px-4 border-t dark:border-slate-800 bg-gray-50 dark:bg-slate-800/30 text-gray-500 dark:text-slate-400 transition-colors">
              <div className="flex items-center gap-2">
                <span className="text-sm font-semibold text-gray-700 whitespace-nowrap">Attach Media for Question (Max 3 Images OR 1 Video/Audio):</span>
                <input 
                  type="file" 
                  accept="image/*,video/*,audio/*"
                  multiple
                  onChange={handleFileChange}
                  className="hidden"
                  id="mc-question-media"
                />
                <label 
                  htmlFor="mc-question-media"
                  className="cursor-pointer bg-gray-100 dark:bg-slate-800 hover:bg-gray-200 dark:hover:bg-slate-700 text-gray-600 dark:text-slate-300 px-3 py-1.5 rounded-md text-xs font-medium border dark:border-slate-700 transition-colors"
                >
                  Select Media
                </label>
              </div>

              {retainedMedia.length > 0 && (
                <div className="mt-2 p-2 bg-gray-50 dark:bg-slate-900/50 rounded-md border dark:border-slate-800 transition-colors">
                  <div className="flex flex-wrap gap-4">
                    {retainedMedia.map((media, idx) => (
                      <div key={`retained-${idx}`} className="flex items-center gap-2 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-md px-2 py-1 pr-1 transition-colors">
                        {media.type?.startsWith('image/') ? (
                          <button 
                            onClick={() => setPreviewImageUrl(getMediaUrl(media.url))}
                            className="text-[10px] font-bold text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 flex items-center gap-1 uppercase tracking-tighter"
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
              )}
            </div>
          </div>
        </div>

        
        <div className="flex items-center gap-6">
          <label className="flex items-center gap-2 text-sm text-gray-700 dark:text-slate-300 cursor-pointer">
            <div className="relative inline-block w-10 mr-2 align-middle select-none transition duration-200 ease-in">
              <input 
                type="checkbox" 
                name="toggle" 
                checked={isMultipleAnswer}
                onChange={(e) => {
                  setIsMultipleAnswer(e.target.checked);
                  setCorrectIds([]); 
                }}
                className={`toggle-checkbox absolute block w-5 h-5 rounded-full bg-white dark:bg-slate-200 border-4 appearance-none cursor-pointer transition-transform duration-200 ${isMultipleAnswer ? 'translate-x-5 border-blue-500 dark:border-blue-400' : 'translate-x-0 border-gray-300 dark:border-slate-700'}`}
              />
              <label className={`toggle-label block overflow-hidden h-5 rounded-full bg-gray-300 dark:bg-slate-800 cursor-pointer ${isMultipleAnswer ? 'bg-blue-500 dark:bg-blue-600' : ''}`}></label>
            </div>
            Multiple answer
          </label>
          
          <label className="flex items-center gap-2 text-sm text-gray-700 dark:text-slate-300 cursor-pointer">
            <div className="relative inline-block w-10 mr-2 align-middle select-none transition duration-200 ease-in">
              <input 
                type="checkbox" 
                name="toggleImage" 
                checked={isAnswerWithImage}
                onChange={(e) => setIsAnswerWithImage(e.target.checked)}
                className={`toggle-checkbox absolute block w-5 h-5 rounded-full bg-white dark:bg-slate-200 border-4 appearance-none cursor-pointer transition-transform duration-200 ${isAnswerWithImage ? 'translate-x-5 border-blue-500 dark:border-blue-400' : 'translate-x-0 border-gray-300 dark:border-slate-700'}`}
              />
              <label className={`toggle-label block overflow-hidden h-5 rounded-full bg-gray-300 dark:bg-slate-800 cursor-pointer ${isAnswerWithImage ? 'bg-blue-500 dark:bg-blue-600' : ''}`}></label>
            </div>
            Answer with image
          </label>
        </div>

        
        <div className="space-y-3">
          {options.map((opt, index) => (
            <div key={opt.id} className="flex items-center gap-3 group">
              <div 
                className="cursor-pointer flex items-center justify-center w-6 h-6 shrink-0"
                onClick={() => handleToggleCorrect(opt.id)}
              >
                <div className={`w-5 h-5 flex items-center justify-center border transition-colors ${isMultipleAnswer ? 'rounded' : 'rounded-full'} ${correctIds.includes(opt.id) ? 'bg-green-500 border-green-500' : 'border-gray-300 dark:border-slate-700 bg-white dark:bg-slate-800 hover:border-green-400 dark:hover:border-green-500'}`}>
                   {correctIds.includes(opt.id) && <div className={`${isMultipleAnswer ? 'w-3 h-3 bg-white' : 'w-2.5 h-2.5 bg-white rounded-full'}`}></div>}
                </div>
              </div>
              
              <div className="flex-1 flex items-center border dark:border-slate-800 rounded-md px-3 py-2 focus-within:ring-1 focus-within:ring-blue-500 dark:focus-within:ring-blue-400 focus-within:border-blue-500 dark:focus-within:border-blue-400 bg-white dark:bg-slate-800 transition-colors">
                 <span className="text-gray-400 dark:text-slate-500 mr-2 font-medium">{String.fromCharCode(65 + index)}.</span>
                 <input 
                   type="text"
                   className="flex-1 outline-none text-gray-700 dark:text-slate-200 bg-transparent"
                   value={opt.label}
                   onChange={(e) => handleOptionChange(opt.id, e.target.value)}
                   placeholder="Type an exact answer..."
                 />
                 {isAnswerWithImage && (
                    <div className="flex items-center gap-2 ml-2">
                       {optionImages[opt.id] ? (
                          <div className="flex items-center gap-2 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-md px-2 py-1 pr-1 transition-colors">
                             <button
                               onClick={() => {
                                 const img = optionImages[opt.id];
                                 if (typeof img === 'string') {
                                   setPreviewImageUrl(getMediaUrl(img));
                                 } else {
                                   setPreviewImageUrl(URL.createObjectURL(img));
                                 }
                               }}
                               className="text-[10px] font-bold text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 flex items-center gap-1 uppercase tracking-tighter"
                             >
                               <Eye size={12} /> View file
                             </button>
                             <button 
                               onClick={() => handleRemoveOptionImage(opt.id)}
                               className="text-red-500 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 rounded p-0.5 transition-colors"
                               title="Remove image"
                             >
                               <X size={14} />
                             </button>
                          </div>
                       ) : (
                          <label className="text-gray-400 dark:text-slate-500 hover:text-blue-600 dark:hover:text-blue-400 cursor-pointer transition-colors">
                            <ImageIcon size={18} />
                            <input 
                              type="file" 
                              className="hidden"
                              accept="image/*"
                              onChange={(e) => {
                                const file = e.target.files?.[0];
                                if (file) handleOptionImageChange(opt.id, file);
                              }}
                            />
                          </label>
                       )}
                    </div>
                 )}
              </div>
              <button 
                onClick={() => handleRemoveOption(opt.id)}
                className="text-gray-400 hover:text-red-500 transition-colors p-1 opacity-0 group-hover:opacity-100"
                title="Remove option"
              >
                <Trash2 size={16} />
              </button>
            </div>
          ))}
          {!isTeacher && (
            <button 
              onClick={handleAddOption}
              className="flex items-center gap-2 text-sm font-medium text-blue-600 hover:text-blue-700 mt-2 pl-9 transition-colors"
            >
              <Plus size={16} /> Add Option
            </button>
          )}
        </div>

        <div className="space-y-2 pt-4 border-t border-dashed dark:border-slate-800">
          <label className="text-sm font-semibold text-gray-800 dark:text-slate-200">Explanation (Optional)</label>
          <div className="border dark:border-slate-800 rounded-md focus-within:ring-1 focus-within:ring-blue-500 dark:focus-within:ring-blue-400 focus-within:border-blue-500 dark:focus-within:border-blue-400 bg-white dark:bg-slate-800 transition-colors">
            <textarea
              className="w-full p-4 border-none focus:ring-0 bg-transparent text-gray-700 dark:text-slate-200 resize-none min-h-[80px] outline-none"
              placeholder="Provide an explanation for the correct answer..."
              value={explanation}
              onChange={(e) => setExplanation(e.target.value)}
            />
          </div>
        </div>
      </div>

      <div className="bg-gray-50 dark:bg-slate-800/50 p-4 border-t dark:border-slate-800 flex items-center justify-end transition-colors">
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
