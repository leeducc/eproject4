import React from 'react';
import { Sparkles, Loader2 } from 'lucide-react';

interface AIGeneratingOverlayProps {
  isOpen: boolean;
  word: string;
  onCancel: () => void;
}

export const AIGeneratingOverlay: React.FC<AIGeneratingOverlayProps> = ({ isOpen, word, onCancel }) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center bg-[#0B0F1A]/80 backdrop-blur-md transition-all duration-500">
      <div className="relative p-8 rounded-3xl bg-[#1A2235]/60 border border-blue-500/30 shadow-[0_0_50px_-12px_rgba(59,130,246,0.3)] max-w-md w-full text-center overflow-hidden">
        {}
        <div className="absolute -top-24 -left-24 w-48 h-48 bg-blue-600/20 blur-[80px] rounded-full animate-pulse" />
        <div className="absolute -bottom-24 -right-24 w-48 h-48 bg-indigo-600/20 blur-[80px] rounded-full animate-pulse" />

        <div className="relative z-10 space-y-6">
          <div className="flex justify-center">
            <div className="relative">
              <div className="absolute inset-0 bg-blue-500/20 blur-xl rounded-full scale-150 animate-pulse" />
              <div className="relative bg-gradient-to-br from-blue-500 to-indigo-600 p-5 rounded-2xl shadow-lg ring-1 ring-white/20">
                <Sparkles size={40} className="text-white animate-[spin_3s_linear_infinite]" />
              </div>
            </div>
          </div>

          <div className="space-y-2">
            <h2 className="text-2xl font-bold bg-gradient-to-r from-blue-400 to-indigo-400 bg-clip-text text-transparent">
              AI is Thinking...
            </h2>
            <p className="text-gray-400 text-sm">
              Generating premium definition and practice set for 
              <span className="text-blue-400 font-semibold mx-1 italic">"{word}"</span>
            </p>
          </div>

          <div className="flex flex-col items-center gap-4 py-4">
            <div className="w-full bg-gray-800/50 h-1.5 rounded-full overflow-hidden border border-gray-700/50">
              <div className="h-full bg-gradient-to-r from-blue-500 to-indigo-500 rounded-full animate-[loading_2s_ease-in-out_infinite]" style={{ width: '40%' }} />
            </div>
            
            <div className="flex items-center gap-2 text-xs text-blue-400/80 font-medium">
              <Loader2 size={14} className="animate-spin" />
              Analyzing patterns, generating quizzes...
            </div>
          </div>

          <div className="pt-2 flex flex-col items-center gap-4">
            <button
              onClick={onCancel}
              className="px-6 py-2 bg-red-500/10 hover:bg-red-500/20 text-red-400 text-xs font-bold uppercase tracking-widest rounded-xl border border-red-500/20 transition-all active:scale-95"
            >
              Cancel Generation
            </button>
            <div className="text-[10px] text-gray-500 uppercase tracking-widest font-bold">
              Powered by Ollama Local AI
            </div>
          </div>
        </div>
      </div>

      <style dangerouslySetInnerHTML={{ __html: `
        @keyframes loading {
          0% { width: 0%; transform: translateX(-100%); }
          50% { width: 40%; transform: translateX(100%); }
          100% { width: 0%; transform: translateX(250%); }
        }
      `}} />
    </div>
  );
};
