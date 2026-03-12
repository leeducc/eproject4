import React, { useState } from 'react';
import { useQuizBankStore } from '../store';
import { DifficultyBand, Question } from '../types';
import { X } from 'lucide-react';
import { toast, ConfirmDialog } from '@english-learning/ui';

export interface WritingBuilderProps {
  initialQuestion?: Question | null;
  onSave?: () => void;
}

export const WritingBuilder: React.FC<WritingBuilderProps> = ({ initialQuestion, onSave }) => {
  const { createQuestion, updateQuestion } = useQuizBankStore();
  
  const [difficultyBand, setDifficultyBand] = useState<DifficultyBand>(initialQuestion?.difficultyBand || 'BAND_5_6');
  const [instruction, setInstruction] = useState(initialQuestion?.instruction || 'Write an essay about the following topic...');
  const [explanation, setExplanation] = useState(initialQuestion?.explanation || '');
  const [isPremium, setIsPremium] = useState<boolean>(initialQuestion?.isPremiumContent || false);
  const [mediaFiles, setMediaFiles] = useState<File[]>([]);
  
  const initialMediaItems = (initialQuestion?.mediaUrls || []).map((url, i) => ({
    url,
    type: initialQuestion?.mediaTypes?.[i] || ''
  }));
  const [retainedMedia, setRetainedMedia] = useState<{url: string; type: string}[]>(initialMediaItems);
  
  const [fileToDelete, setFileToDelete] = useState<{ type: 'new' | 'retained', index: number } | null>(null);
  


  const handleSave = () => {
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
      updateQuestion(initialQuestion.id, payload, mediaFiles);
    } else {
      console.log('[WritingBuilder] Saving a writing question', { instruction });
      createQuestion(payload, mediaFiles);
    }
    if (onSave) onSave();
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!e.target.files?.length) return;
    const newFiles = Array.from(e.target.files);
    const countImages = retainedMedia.filter(m => m.type.startsWith('image/')).length + 
                        mediaFiles.filter(f => f.type.startsWith('image/')).length +
                        newFiles.filter(f => f.type.startsWith('image/')).length;
                        
    const countAV = retainedMedia.filter(m => !m.type.startsWith('image/')).length + 
                    mediaFiles.filter(f => !f.type.startsWith('image/')).length +
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
    setMediaFiles(prev => [...prev, ...newFiles]);
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
            id="premium-writing"
            checked={isPremium}
            onChange={(e) => setIsPremium(e.target.checked)}
            className="w-4 h-4 text-amber-500 rounded border-gray-300 focus:ring-amber-500"
          />
          <label htmlFor="premium-writing" className="text-sm font-medium text-gray-700 flex items-center gap-1">Premium Content</label>
        </div>
      </div>

      {/* Main Content */}
      <div className="p-6 space-y-6">
        <div className="space-y-3">
          <label className="text-sm font-semibold text-gray-800">Writing Prompt / Task Description</label>
          <p className="text-sm text-gray-500 mb-2">
            Provide the topic, images, or stimulus material for the writing task here. There are no "correct answers" to set as this requires manual or AI grading later.
          </p>
          <div className="border rounded-md focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500 bg-gray-50/50 flex flex-col justify-between">
            <div className="p-2 pb-0">
               <textarea
                 className="w-full p-2 bg-transparent border-none focus:ring-0 resize-none outline-none font-medium text-gray-800 min-h-[150px]"
                 placeholder="Type your prompt here..."
                 value={instruction}
                 onChange={(e) => setInstruction(e.target.value)}
               />
            </div>
            <div className="flex flex-col gap-2 p-3 bg-white border-t">
              <div className="flex items-center gap-2">
                <span className="text-sm font-semibold text-gray-700">Attach Media (Max 3 Images OR 1 Video/Audio):</span>
                <input 
                  type="file" 
                  accept="image/*,video/*,audio/*"
                  multiple
                  onChange={handleFileChange}
                  className="text-sm text-gray-600 file:mr-4 file:py-1 file:px-3 file:rounded-md file:border-0 file:text-sm file:font-medium file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 outline-none"
                />
              </div>
              
              {(retainedMedia.length > 0 || mediaFiles.length > 0) && (
                <div className="mt-2 text-sm text-gray-500">
                  <div className="font-semibold mb-2">Media Previews:</div>
                  <div className="flex flex-wrap gap-4">
                    {/* Retained Media previews */}
                    {retainedMedia.map((media, idx) => (
                      <div key={`retained-${idx}`} className="relative border rounded p-1 inline-block">
                        <button 
                          onClick={() => removeRetainedMedia(idx)}
                          className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-0.5"
                        >
                          <X size={14} />
                        </button>
                        {media.type?.startsWith('image/') ? (
                          <img src={`http://localhost${media.url}`} alt="Preview" className="max-h-32 object-contain" />
                        ) : media.type?.startsWith('video/') ? (
                          <video src={`http://localhost${media.url}`} controls className="max-h-32 w-64 max-w-full" />
                        ) : media.type?.startsWith('audio/') ? (
                          <audio src={`http://localhost${media.url}`} controls className="w-64 max-w-full" />
                        ) : (
                          <a href={`http://localhost${media.url}`} target="_blank" rel="noreferrer" className="text-blue-500 underline">View File</a>
                        )}
                      </div>
                    ))}

                    {/* New Files Previews */}
                    {mediaFiles.map((file, idx) => {
                       const objectUrl = URL.createObjectURL(file);
                       return (
                         <div key={`new-${idx}`} className="relative border border-blue-200 bg-blue-50 rounded p-1 inline-block">
                           <button 
                             onClick={() => removeNewFile(idx)}
                             className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-0.5"
                           >
                             <X size={14} />
                           </button>
                           {file.type.startsWith('image/') ? (
                             <img src={objectUrl} alt="Preview" className="max-h-32 object-contain" onLoad={() => URL.revokeObjectURL(objectUrl)} />
                           ) : file.type.startsWith('video/') ? (
                             <video src={objectUrl} controls className="max-h-32 w-64 max-w-full" />
                           ) : file.type.startsWith('audio/') ? (
                             <audio src={objectUrl} controls className="w-64 max-w-full" />
                           ) : (
                             <div className="p-4">{file.name}</div>
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
        <div className="space-y-2 pt-4 border-t border-dashed">
          <label className="text-sm font-semibold text-gray-800">Explanation / Grading Rubric (Optional)</label>
          <div className="border rounded-md focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500 bg-white">
            <textarea
              className="w-full p-4 border-none focus:ring-0 resize-none min-h-[80px] outline-none"
              placeholder="Provide an explanation or grading rubric for this writing task..."
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
    </div>
  );
};
