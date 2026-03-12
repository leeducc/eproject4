import React, { useState, useRef } from 'react';
import { useQuizBankStore } from '../store';
import { FillBlankData, DifficultyBand, SkillType, Question } from '../types';
import { Plus, Trash2, Edit2, X, Eye } from 'lucide-react';
import { toast, ConfirmDialog } from '@english-learning/ui';
import { getMediaUrl } from '../utils';

export interface FillInTheBlankBuilderProps {
  skill?: SkillType;
  initialQuestion?: Question | null;
  onSave?: () => void;
}

export const FillInTheBlankBuilder: React.FC<FillInTheBlankBuilderProps> = ({ skill = 'READING', initialQuestion, onSave }) => {
  const { currentUser, createQuestion, updateQuestion, uploadMedia } = useQuizBankStore();
  const isTeacher = currentUser.role === 'TEACHER';
  const [difficultyBand, setDifficultyBand] = useState<DifficultyBand>(initialQuestion?.difficultyBand || 'BAND_5_6');
  const [instruction, setInstruction] = useState(initialQuestion?.instruction || 'Fill in the blanks with the correct words.');
  const [explanation, setExplanation] = useState(initialQuestion?.explanation || '');
  const [isPremium, setIsPremium] = useState<boolean>(initialQuestion?.isPremiumContent || false);
  const [mediaFiles, setMediaFiles] = useState<File[]>([]);
  const [previewImageUrl, setPreviewImageUrl] = useState<string | null>(null);

  const initialMediaItems = (initialQuestion?.mediaUrls || []).map((url, i) => ({
    url,
    type: initialQuestion?.mediaTypes?.[i] || ''
  }));
  const [retainedMedia, setRetainedMedia] = useState<{ url: string; type: string }[]>(initialMediaItems);

  const [fileToDelete, setFileToDelete] = useState<{ type: 'new' | 'retained', index: number } | null>(null);

  const existingData = initialQuestion?.data as FillBlankData | undefined;
  const [template, setTemplate] = useState(existingData?.template || 'When selecting a style, consider your [blank1].');

  // Active blanks dictionary
  const [blanks, setBlanks] = useState<Record<string, { correct: string[]; max_words: number }>>(existingData?.blanks || {
    'blank1': { correct: ['Audience'], max_words: 1 }
  });

  // Distractor answer pool
  const [answerPool, setAnswerPool] = useState<string[]>(existingData?.answer_pool || ['Direction', 'Tone']);


  const [isEditing, setIsEditing] = useState(false);

  const textareaRef = useRef<HTMLTextAreaElement>(null);

  // Parse template into text chunks and blank tokens for visual display
  const renderTemplateTokens = () => {
    // regex to find [blankN]
    const regex = /(\[blank\d+\])/g;
    const parts = template.split(regex);

    return parts.map((part, index) => {
      const match = part.match(/\[blank(\d+)\]/);
      if (match) {
        const blankId = part.replace(/[\[\]]/g, ''); // "blank1"
        const num = match[1];
        const blankData = blanks[blankId];
        const label = blankData && blankData.correct.length > 0 ? blankData.correct[0] : '...';
        return (
          <span key={index} className="inline-flex items-center justify-center bg-blue-100 text-blue-800 border-blue-200 border rounded-full px-3 py-1 mx-1 font-medium text-sm">
            <span className="bg-white text-blue-600 rounded-full w-4 h-4 flex items-center justify-center text-[10px] mr-1 border border-blue-200">{num}</span>
            {label}
          </span>
        );
      }
      return <span key={index} className="text-gray-700 leading-relaxed max-w-none">{part}</span>;
    });
  };

  const handleCreateBlank = () => {
    if (!textareaRef.current) return;
    const { selectionStart, selectionEnd, value } = textareaRef.current;

    if (selectionStart === selectionEnd) {
      toast.error("Please highlight a word first to create a blank.");
      return;
    }

    const selectedText = value.substring(selectionStart, selectionEnd).trim();
    if (!selectedText) return;

    // Find next available blank ID
    let nextId = 1;
    while (blanks[`blank${nextId}`]) {
      nextId++;
    }
    const newBlankId = `blank${nextId}`;

    const newTemplate = value.substring(0, selectionStart) + `[${newBlankId}]` + value.substring(selectionEnd);

    setTemplate(newTemplate);
    setBlanks({
      ...blanks,
      [newBlankId]: { correct: [selectedText], max_words: selectedText.split(' ').length }
    });

    // reset selection
    setTimeout(() => {
      if (textareaRef.current) {
        textareaRef.current.focus();
        textareaRef.current.setSelectionRange(selectionStart, selectionStart + newBlankId.length + 2);
      }
    }, 0);
  };

  const syncBlanksWithTemplate = (newDraft: string) => {
    let currentTemplate = newDraft;
    const newBlanks = { ...blanks };
    let changed = false;

    // 1. Find all [...] matches
    const regex = /\[(.*?)\]/g;
    const matches = Array.from(newDraft.matchAll(regex));

    // 2. Track which blanks are actually present
    const presentBlankIds = new Set<string>();

    for (const match of matches) {
      const content = match[1].trim();
      const fullMatch = match[0];
      const matchIndex = match.index!;

      // Case A: content is [blankN] or [blank N]
      const blankMatch = content.match(/^blank\s*(\d+)$/i);
      if (blankMatch) {
        const id = `blank${blankMatch[1]}`;
        presentBlankIds.add(id);

        // Normalize [blank 1] to [blank1] if needed
        if (content !== id) {
          currentTemplate = currentTemplate.substring(0, matchIndex) + `[${id}]` + currentTemplate.substring(matchIndex + fullMatch.length);
          changed = true;
        }

        // Ensure state has this ID (might be new if user typed [blank5])
        if (!newBlanks[id]) {
          newBlanks[id] = { correct: [''], max_words: 1 };
          changed = true;
        }
      }
      // Case B: content is [some word] - transform to blank
      else {
        let nextId = 1;
        while (newBlanks[`blank${nextId}`] || presentBlankIds.has(`blank${nextId}`)) {
          nextId++;
        }
        const newId = `blank${nextId}`;
        presentBlankIds.add(newId);

        newBlanks[newId] = { correct: [content], max_words: content.split(/\s+/).length };
        currentTemplate = currentTemplate.substring(0, matchIndex) + `[${newId}]` + currentTemplate.substring(matchIndex + fullMatch.length);
        changed = true;
      }
    }

    // 3. Remove blanks no longer in template
    Object.keys(newBlanks).forEach(id => {
      if (!presentBlankIds.has(id)) {
        delete newBlanks[id];
        changed = true;
      }
    });

    setTemplate(currentTemplate);
    if (changed) {
      setBlanks(newBlanks);
    }
  };

  const handleUpdateBlankLabel = (id: string, index: number, newLabel: string) => {
    const newBlanks = { ...blanks };
    const correct = [...newBlanks[id].correct];
    correct[index] = newLabel;
    newBlanks[id] = { ...newBlanks[id], correct };
    setBlanks(newBlanks);
  };

  const handleAddSynonym = (id: string) => {
    const newBlanks = { ...blanks };
    newBlanks[id] = {
      ...newBlanks[id],
      correct: [...newBlanks[id].correct, '']
    };
    setBlanks(newBlanks);
  };

  const handleDeleteSynonym = (id: string, index: number) => {
    const newBlanks = { ...blanks };
    if (newBlanks[id].correct.length <= 1) return;
    newBlanks[id].correct = newBlanks[id].correct.filter((_, i) => i !== index);
    setBlanks(newBlanks);
  };

  const handleCreateNewBlankEntry = () => {
    let nextId = 1;
    while (blanks[`blank${nextId}`]) {
      nextId++;
    }
    const id = `blank${nextId}`;
    setBlanks({
      ...blanks,
      [id]: { correct: [''], max_words: 1 }
    });
    setTemplate(prev => prev + (prev.endsWith(' ') ? '' : ' ') + `[${id}]`);
  };

  const handleDeleteBlank = (id: string) => {
    if (isTeacher) return;
    // Remove from template
    const newTemplate = template.replace(`[${id}]`, blanks[id]?.correct[0] || '');
    syncBlanksWithTemplate(newTemplate);
  };

  const handleAddDistractor = () => {
    setAnswerPool([...answerPool, 'New Option']);
  };

  const handleUpdateDistractor = (index: number, val: string) => {
    const newPool = [...answerPool];
    newPool[index] = val;
    setAnswerPool(newPool);
  };

  const handleDeleteDistractor = (index: number) => {
    if (isTeacher) return;
    setAnswerPool(answerPool.filter((_, i) => i !== index));
  };

  const handleSave = async () => {
    if (!instruction.trim()) {
      toast.error("Please provide an instruction.");
      return;
    }
    if (!template.trim()) {
      toast.error("Please provide the sentence template.");
      return;
    }
    if (Object.keys(blanks).length === 0) {
      toast.error("Please create at least one blank in the sentence.");
      return;
    }
    for (const key in blanks) {
      if (!blanks[key].correct[0] || !blanks[key].correct[0].trim()) {
        toast.error("Please fill in the correct answer for all blanks.");
        return;
      }
    }

    const data: FillBlankData = {
      template,
      blanks,
      answer_pool: answerPool.length > 0 ? answerPool : undefined,
    };

    const retainedMediaUrls = retainedMedia.map(m => m.url);
    const payload = {
      skill,
      type: 'FILL_BLANK' as const,
      difficultyBand: difficultyBand,
      instruction,
      explanation,
      data,
      isPremiumContent: isPremium,
      retainedMediaUrls
    };

    if (initialQuestion) {
      console.log('[FillInTheBlankBuilder] Updating question', { data });
      await updateQuestion(initialQuestion.id, payload);
    } else {
      console.log('[FillInTheBlankBuilder] Saving question', { data });
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
            id="premium-fib"
            checked={isPremium}
            onChange={(e) => setIsPremium(e.target.checked)}
            className="w-4 h-4 text-amber-500 rounded border-gray-300 focus:ring-amber-500"
          />
          <label htmlFor="premium-fib" className="text-sm font-medium text-gray-700 flex items-center gap-1">Premium Content</label>
        </div>
      </div>

      {/* Main Content */}
      <div className="p-6 space-y-6">

        {/* Question Input */}
        <div className="space-y-2">
          <div className="flex items-center gap-2 text-sm font-bold text-gray-800 bg-gray-100 w-max px-2 py-1 rounded">
            <span className="bg-gray-800 text-white rounded w-4 h-4 flex items-center justify-center text-[10px]">?</span>
            Question / Instruction
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
                          <button 
                            type="button"
                            onClick={() => setPreviewImageUrl(getMediaUrl(media.url))}
                            className="bg-blue-50 text-blue-600 border border-blue-200 px-2 py-1 rounded text-[10px] font-bold uppercase tracking-tight flex items-center gap-1 hover:bg-blue-100 transition-colors"
                          >
                            <Eye size={12} /> View file
                          </button>
                        ) : media.type?.startsWith('video/') ? (
                          <video src={getMediaUrl(media.url)} controls className="max-h-32 w-64 max-w-full" />
                        ) : media.type?.startsWith('audio/') ? (
                          <audio src={getMediaUrl(media.url)} controls className="w-64 max-w-full" />
                        ) : (
                          <a href={getMediaUrl(media.url)} target="_blank" rel="noreferrer" className="text-blue-500 underline text-xs">View File</a>
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

        {/* Interactive Editor Area */}
        <div className="space-y-3">
          <label className="text-sm font-semibold text-gray-800">Sentence Editor</label>
          <p className="text-sm text-gray-500 mb-2">
            Type your sentence below. Highlight a word and click "Create Blank" to convert it.
          </p>

          <div className="border rounded-md focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500 bg-white relative overflow-hidden flex flex-col">
            {/* Toolbar */}
            <div className="flex items-center justify-between p-2 px-4 border-b bg-gray-50">
              <button
                onClick={handleCreateBlank}
                className="flex items-center gap-2 text-sm text-blue-600 font-medium hover:text-blue-700 bg-blue-50 px-3 py-1.5 rounded-md border border-blue-200"
              >
                <Edit2 size={14} /> Create Blank from Selection
              </button>

              <button
                onClick={() => setIsEditing(!isEditing)}
                className="text-sm text-gray-600 hover:text-gray-800 underline"
              >
                {isEditing ? 'View Preview' : 'Edit Raw Text'}
              </button>
            </div>

            {/* Editor body */}
            <div className="relative min-h-[120px] p-4 bg-white text-base">
              {isEditing ? (
                <textarea
                  ref={textareaRef}
                  className="w-full h-full min-h-[120px] outline-none resize-none bg-transparent"
                  value={template}
                  onChange={(e) => syncBlanksWithTemplate(e.target.value)}
                  placeholder="Type a sentence here..."
                />
              ) : (
                <div
                  className="w-full h-full min-h-[120px] cursor-text"
                  onClick={() => setIsEditing(true)}
                >
                  {renderTemplateTokens()}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Answer Options Display (Correct answers and distractors) */}
        <div className="space-y-4 pt-4 border-t border-dashed">
          <label className="text-sm font-semibold text-gray-800">Answer Pool & Options</label>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Core Blanks List */}
            <div className="space-y-3">
              <div className="flex items-center justify-between mb-2">
                <h4 className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Blanks (Correct Answers)</h4>
                <button
                  onClick={handleCreateNewBlankEntry}
                  className="text-[10px] bg-blue-50 text-blue-600 hover:bg-blue-100 px-2 py-0.5 rounded border border-blue-200 font-bold uppercase tracking-tighter"
                >
                  + Add Correct Answer
                </button>
              </div>

              {Object.entries(blanks).map(([id, blankData]) => {
                const num = id.replace('blank', '');
                return (
                  <div key={id} className="space-y-2 bg-gray-50 border rounded-md p-3 group relative">
                    <div className="flex items-center gap-2 mb-1">
                      <div className="bg-white border rounded-full w-5 h-5 flex items-center justify-center text-[10px] font-bold text-gray-500 shadow-sm shrink-0">
                        {num}
                      </div>
                      <span className="text-[10px] font-bold text-gray-400 uppercase">Blank {num}</span>
                      {!isTeacher && (
                        <button
                          onClick={() => handleDeleteBlank(id)}
                          className="ml-auto text-gray-300 hover:text-red-500 transition-colors"
                        >
                          <Trash2 size={14} />
                        </button>
                      )}
                    </div>

                    {/* Synonyms List */}
                    <div className="space-y-2 pl-7">
                      {blankData.correct.map((val, idx) => (
                        <div key={`${id}-synonym-${idx}`} className="flex items-center gap-2">
                          <input
                            className="flex-1 bg-white border border-gray-200 rounded px-2 py-1 text-sm text-gray-800 font-medium focus:ring-1 focus:ring-blue-500 outline-none"
                            value={val}
                            onChange={(e) => handleUpdateBlankLabel(id, idx, e.target.value)}
                            placeholder={idx === 0 ? "Main correct answer..." : "Synonym..."}
                          />
                          {blankData.correct.length > 1 && (
                            <button
                              onClick={() => handleDeleteSynonym(id, idx)}
                              className="text-gray-300 hover:text-red-400"
                            >
                              <X size={14} />
                            </button>
                          )}
                        </div>
                      ))}
                      <button
                        onClick={() => handleAddSynonym(id)}
                        className="text-[10px] text-blue-500 hover:text-blue-600 font-bold flex items-center gap-1"
                      >
                        <Plus size={10} /> Add Synonym
                      </button>
                    </div>
                  </div>
                );
              })}
              {Object.keys(blanks).length === 0 && (
                <p className="text-sm text-gray-400 italic">No blanks created yet.</p>
              )}
            </div>

            {/* Distractors List */}
            <div className="space-y-3">
              <h4 className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">Distractors (Incorrect)</h4>
              {answerPool.map((distractor, index) => (
                <div key={`distractor-${index}`} className="flex items-center gap-2 bg-gray-50 border rounded-md p-2 group border-orange-100 bg-orange-50/30">
                  <div className="w-6 h-6 shrink-0 flex items-center justify-center text-orange-400">
                    <span className="w-1.5 h-1.5 rounded-full bg-orange-400"></span>
                  </div>
                  <input
                    className="flex-1 bg-transparent outline-none text-sm text-gray-800 font-medium"
                    value={distractor}
                    onChange={(e) => handleUpdateDistractor(index, e.target.value)}
                    placeholder="Incorrect answer..."
                  />
                  {!isTeacher && (
                    <button
                      onClick={() => handleDeleteDistractor(index)}
                      className="opacity-0 group-hover:opacity-100 text-gray-400 hover:text-red-500 p-1"
                    >
                      <Trash2 size={16} />
                    </button>
                  )}
                </div>
              ))}

              <button
                onClick={handleAddDistractor}
                className="flex items-center gap-1 text-sm text-orange-600 font-medium hover:text-orange-700 mt-2"
              >
                <Plus size={16} /> Add incorrect answer
              </button>
            </div>
          </div>
        </div>

        {/* Explanation Input */}
        <div className="space-y-2 pt-4 border-t border-dashed">
          <label className="text-sm font-semibold text-gray-800">Explanation (Optional)</label>
          <div className="border rounded-md focus-within:ring-1 focus-within:ring-blue-500 focus-within:border-blue-500 bg-white">
            <textarea
              className="w-full p-4 border-none focus:ring-0 resize-none min-h-[80px] outline-none"
              placeholder="Provide an explanation for the correct answers..."
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
            />
          </div>
        </div>
      )}
    </div>
  );
};
