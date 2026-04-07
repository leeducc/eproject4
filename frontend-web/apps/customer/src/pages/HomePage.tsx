import React from 'react';
import { useTheme } from '@english-learning/ui';
import { Sun, Moon } from 'lucide-react';

interface HomePageProps {
  onLogout: () => void;
}

const HomePage: React.FC<HomePageProps> = ({ onLogout }) => {
  const { theme, setTheme } = useTheme();

  return (
    <div className="min-h-screen bg-slate-50 dark:bg-slate-950 text-slate-900 dark:text-white flex flex-col transition-colors duration-300">
      <header className="p-6 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 flex justify-between items-center transition-colors duration-300">
        <h1 className="text-2xl font-bold bg-gradient-to-r from-green-400 to-blue-500 bg-clip-text text-transparent">
          English Learning Dashboard
        </h1>
        <div className="flex items-center gap-4">
          <button
            onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
            className="p-2 rounded-full hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
            title="Toggle Theme"
          >
            {theme === 'dark' ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5 text-slate-600" />}
          </button>
          <button
            onClick={onLogout}
            className="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-md font-medium transition-all transform hover:scale-105"
          >
            Logout
          </button>
        </div>
      </header>
      <main className="flex-1 flex flex-col items-center justify-center p-10">
        <div className="text-center space-y-4">
          <h2 className="text-4xl font-extrabold text-slate-900 dark:text-white">Welcome, Customer!</h2>
          <p className="text-slate-500 dark:text-slate-400 text-xl max-w-lg">
            This is your personalized learning dashboard. New features are coming soon!
          </p>
          <div className="mt-8 grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="p-6 bg-white dark:bg-slate-800 rounded-xl border border-slate-200 dark:border-slate-700 hover:border-blue-500 transition-colors cursor-pointer group shadow-sm">
              <div className="h-12 w-12 bg-blue-500/20 rounded-full flex items-center justify-center mb-4 group-hover:bg-blue-500/40 transition-colors">
                <span className="text-blue-500 font-bold text-xl">L</span>
              </div>
              <h3 className="text-xl font-semibold mb-2">Lessons</h3>
              <p className="text-sm text-slate-500 dark:text-slate-400">Pick up where you left off in your latest lesson.</p>
            </div>
            <div className="p-6 bg-white dark:bg-slate-800 rounded-xl border border-slate-200 dark:border-slate-700 hover:border-green-500 transition-colors cursor-pointer group shadow-sm">
              <div className="h-12 w-12 bg-green-500/20 rounded-full flex items-center justify-center mb-4 group-hover:bg-green-500/40 transition-colors">
                <span className="text-green-500 font-bold text-xl">P</span>
              </div>
              <h3 className="text-xl font-semibold mb-2">Practice</h3>
              <p className="text-sm text-slate-500 dark:text-slate-400">Hone your skills with interactive exercises.</p>
            </div>
            <div className="p-6 bg-white dark:bg-slate-800 rounded-xl border border-slate-200 dark:border-slate-700 hover:border-purple-500 transition-colors cursor-pointer group shadow-sm">
              <div className="h-12 w-12 bg-purple-500/20 rounded-full flex items-center justify-center mb-4 group-hover:bg-purple-500/40 transition-colors">
                <span className="text-purple-500 font-bold text-xl">S</span>
              </div>
              <h3 className="text-xl font-semibold mb-2">Stats</h3>
              <p className="text-sm text-slate-500 dark:text-slate-400">Track your progress and achievements.</p>
            </div>
          </div>
        </div>
      </main>
      <footer className="p-6 text-center text-slate-500 text-sm border-t border-slate-100 dark:border-slate-900 transition-colors duration-300">
        &copy; 2026 English Learning Platform. All rights reserved.
      </footer>
    </div>
  );
};

export default HomePage;
