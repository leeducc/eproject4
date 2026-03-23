import React, { useState } from 'react';
import { useQuizBankStore } from '../store';
import { DifficultyBand, Question } from '../types';
import { X, Eye } from 'lucide-react';
import { toast, ConfirmDialog } from '@english-learning/ui';
import { getMediaUrl } from '../utils';

export interface WritingBuilderProps {
  initialQuestion?: Question | null;
  onSave?: () => void;
}

export const WritingBuilder: React.FC<WritingBuilderProps> = ({ initialQuestion, onSave }) => {
  const { createQuestion, updateQuestion, uploadMedia } = useQuizBankStore();
  
  const [difficultyBand, setDifficultyBand] = useState<DifficultyBand>(initialQuestion?.difficultyBand || 'BAND_5_6');
  const [instruction, setInstruction] = useState(initialQuestion?.instruction || 'Write an essay about the following topic...');
  const [explanation, setExplanation] = useState(initialQuestion?.explanation || '');
  const [isPremium, setIsPremium] = useState<boolean>(initialQuestion?.isPremiumContent || false);
  const [mediaFiles, setMediaFiles] = useState<File[]>([]);
  const [previewImageUrl, setPreviewImageUrl] = useState<string | null>(null);
  
  const initialMediaItems = (initialQuestion?.mediaUrls || []).map((url, i) => ({
    url,
    type: initialQuestion?.mediaTypes?.[i] || ''
  }));
  const [retainedMedia, setRetainedMedia] = useState<{url: string; type: string}[]>(initialMediaItems);
  
  const [fileToDelete, setFileToDelete] = useState<{ type: 'new' | 'retained', index: number } | null>(null);
  


  const handleSave = async () => {
    if (!instruction.trim()) {
      toast.error("Please provide the writing prompt.");
      return;
    }

    // There's no specific answers data needed for a writing question, keeping it generic.
    const retainedMediaUrls = retainedMedia.map(m => m.url);
    const payload = {
      skill: 'WRITING' as const, // Special type technically
      type: 'ESSAY' as const, // Correctly categorized as ESSAY
      difficultyBand: difficultyBand,
      instruction,
      explanation,
      data: initialQuestion?.data || { template: '', blanks: {} }, // Mock payload for typing
      isPremiumContent: isPremium,
      retainedMediaUrls
    };
    if (initialQuestion) {
      console.log('[WritingBuilder] Updating a writing question', { instruction });
      await updateQuestion(initialQuestion.id, payload);
    } else {
      console.log('[WritingBuilder] Saving a writing question', { instruction });
      await createQuestion(payload);
    }
    if (onSave) onSave();
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
    
    if (fileToDelete.type === 'new') {
      setMediaFiles(prev => prev.filter((_, i) => i !== fileToDelete.index));
    } else {
      setRetainedMedia(prev => prev.filter((_, i) => i !== fileToDelete.index));
    }
    setFileToDelete(null);
    toast.success("File removed");
  };

  const removeNewFile = (index: number) => {
    setFileToDelete({ type: 'new', index });
  };
  const removeRetainedMedia = (index: number) => {
    setFileToDelete({ type: 'retained', index });
  };

  return (
    <div className="bg-white dark:bg-slate-900 border dark:border-slate-800 rounded-lg shadow-sm w-full max-w-4xl mx-auto p-0 overflow-hidden font-sans mt-8 transition-colors">
      {/* Header */}
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
            id="premium-writing"
            checked={isPremium}
            onChange={(e) => setIsPremium(e.target.checked)}
            className="w-4 h-4 text-amber-500 rounded border-gray-300 dark:border-slate-700 bg-white dark:bg-slate-800 focus:ring-amber-500"
          />
          <label htmlFor="premium-writing" className="text-sm font-medium text-gray-700 dark:text-slate-300 flex items-center gap-1">Premium Content</label>
        </div>
      </div>

      {/* Main Content */}
      <div className="p-6 space-y-6">
        <div className="space-y-3">
          <label className="text-sm font-semibold text-gray-800 dark:text-slate-200">Writing Prompt / Task Description</label>
          <p className="text-sm text-gray-500 dark:text-slate-400 mb-2">
            Provide the topic, images, or stimulus material for the writing task here. There are no "correct answers" to set as this requires manual or AI grading later.
          </p>
          <div className="border dark:border-slate-800 rounded-md focus-within:ring-1 focus-within:ring-blue-500 dark:focus-within:ring-blue-400 focus-within:border-blue-500 dark:focus-within:border-blue-400 bg-gray-50/50 dark:bg-slate-800/30 flex flex-col justify-between transition-colors">
            <div className="p-2 pb-0">
               <textarea
                 className="w-full p-2 bg-transparent border-none focus:ring-0 resize-none outline-none font-medium text-gray-800 dark:text-slate-200 min-h-[150px]"
                 placeholder="Type your prompt here..."
                 value={instruction}
                 onChange={(e) => setInstruction(e.target.value)}
               />
            </div>
            <div className="flex flex-col gap-2 p-3 bg-white dark:bg-slate-800/50 border-t dark:border-slate-800 transition-colors">
              <div className="flex items-center gap-2">
                <span className="text-sm font-semibold text-gray-700 dark:text-slate-300">Attach Media (Max 3 Images OR 1 Video/Audio):</span>
                <input 
                  type="file" 
                  accept="image/*,video/*,audio/*"
                  multiple
                  onChange={handleFileChange}
                  className="text-sm text-gray-600 dark:text-slate-400 file:mr-4 file:py-1 file:px-3 file:rounded-md file:border-0 file:text-sm file:font-medium file:bg-blue-50 dark:file:bg-blue-900/40 file:text-blue-700 dark:file:text-blue-300 hover:file:bg-blue-100 dark:hover:file:bg-blue-900/60 transition-colors outline-none"
                />
              </div>
              
              {(retainedMedia.length > 0 || mediaFiles.length > 0) && (
                <div className="mt-2 text-sm text-gray-500 dark:text-slate-400">
                  <div className="font-semibold mb-2 text-gray-700 dark:text-slate-300">Media Previews:</div>
                  <div className="flex flex-wrap gap-4">
                    {/* Retained Media previews */}
                    {retainedMedia.map((media, idx) => (
                      <div key={`retained-${idx}`} className="relative border dark:border-slate-800 rounded p-1 inline-block transition-colors">
                        <button 
                          onClick={() => removeRetainedMedia(idx)}
                          className="absolute -top-2 -right-2 bg-red-500 dark:bg-red-600 text-white rounded-full p-0.5 shadow-sm z-10"
                        >
                          <X size={14} />
                        </button>
                        {media.type?.startsWith('image/') ? (
                          <button 
                            type="button"
                            onClick={() => setPreviewImageUrl(getMediaUrl(media.url))}
                            className="bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400 border border-blue-200 dark:border-blue-800 px-2 py-1 rounded text-[10px] font-bold uppercase tracking-tight flex items-center gap-1 hover:bg-blue-100 dark:hover:bg-blue-900/40 transition-colors"
                          >
                            <Eye size={12} /> View file
                          </button>
                        ) : media.type?.startsWith('video/') ? (
                          <div className="bg-slate-100 dark:bg-slate-800 rounded overflow-hidden">
                             <video src={getMediaUrl(media.url)} controls className="max-h-32 w-64 max-w-full" />
                          </div>
                        ) : media.type?.startsWith('audio/') ? (
                          <audio src={getMediaUrl(media.url)} controls className="w-64 max-w-full" />
                        ) : (
                          <a href={getMediaUrl(media.url)} target="_blank" rel="noreferrer" className="text-blue-500 dark:text-blue-400 underline text-xs">View File</a>
                        )}
                      </div>
                    ))}

                    {/* New Files Previews */}
                    {mediaFiles.map((file, idx) => {
                       const objectUrl = URL.createObjectURL(file);
                       return (
                         <div key={`new-${idx}`} className="relative border border-blue-200 dark:border-blue-800 bg-blue-50 dark:bg-blue-900/10 rounded p-1 inline-block transition-colors">
                           <button 
                             onClick={() => removeNewFile(idx)}
                             className="absolute -top-2 -right-2 bg-red-500 dark:bg-red-600 text-white rounded-full p-0.5 shadow-sm z-10"
                           >
                             <X size={14} />
                           </button>
                           {file.type.startsWith('image/') ? (
                             <img src={objectUrl} alt="Preview" className="max-h-32 object-contain rounded" onLoad={() => URL.revokeObjectURL(objectUrl)} />
                           ) : file.type.startsWith('video/') ? (
                             <div className="bg-slate-100 dark:bg-slate-800 rounded overflow-hidden">
                               <video src={objectUrl} controls className="max-h-32 w-64 max-w-full" />
                             </div>
                           ) : file.type.startsWith('audio/') ? (
                             <audio src={objectUrl} controls className="w-64 max-w-full" />
                           ) : (
                             <div className="p-4 text-gray-600 dark:text-slate-400">{file.name}</div>
                           )}
                         </div>
                       );
                    })}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Explanation Input */}
        <div className="space-y-2 pt-4 border-t border-dashed dark:border-slate-800 transition-colors">
          <label className="text-sm font-semibold text-gray-800 dark:text-slate-200">Explanation / Grading Rubric (Optional)</label>
          <div className="border dark:border-slate-800 rounded-md focus-within:ring-1 focus-within:ring-blue-500 dark:focus-within:ring-blue-400 focus-within:border-blue-500 dark:focus-within:border-blue-400 bg-white dark:bg-slate-900 transition-colors">
            <textarea
              className="w-full p-4 border-none focus:ring-0 bg-transparent text-gray-700 dark:text-slate-200 resize-none min-h-[80px] outline-none"
              placeholder="Provide an explanation or grading rubric for this writing task..."
              value={explanation}
              onChange={(e) => setExplanation(e.target.value)}
            />
          </div>
        </div>
      </div>

      {/* Footer Settings */}
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

      {/* Full Size Image Preview Modal */}
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
