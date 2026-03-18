import React from 'react';

interface HomePageProps {
  onLogout: () => void;
}

const HomePage: React.FC<HomePageProps> = ({ onLogout }) => {
  return (
    <div className="min-h-screen bg-gray-950 text-white flex flex-col">
      <header className="p-6 bg-gray-900 border-b border-gray-800 flex justify-between items-center">
        <h1 className="text-2xl font-bold bg-gradient-to-r from-green-400 to-blue-500 bg-clip-text text-transparent">
          English Learning Dashboard
        </h1>
        <button
          onClick={onLogout}
          className="px-4 py-2 bg-red-600 hover:bg-red-700 rounded-md font-medium transition-all transform hover:scale-105"
        >
          Logout
        </button>
      </header>
      <main className="flex-1 flex flex-col items-center justify-center p-10">
        <div className="text-center space-y-4">
          <h2 className="text-4xl font-extrabold text-white">Welcome, Customer!</h2>
          <p className="text-gray-400 text-xl max-w-lg">
            This is your personalized learning dashboard. New features are coming soon!
          </p>
          <div className="mt-8 grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="p-6 bg-gray-800 rounded-xl border border-gray-700 hover:border-blue-500 transition-colors cursor-pointer group">
              <div className="h-12 w-12 bg-blue-500/20 rounded-full flex items-center justify-center mb-4 group-hover:bg-blue-500/40 transition-colors">
                <span className="text-blue-500 font-bold text-xl">L</span>
              </div>
              <h3 className="text-xl font-semibold mb-2">Lessons</h3>
              <p className="text-sm text-gray-500">Pick up where you left off in your latest lesson.</p>
            </div>
            <div className="p-6 bg-gray-800 rounded-xl border border-gray-700 hover:border-green-500 transition-colors cursor-pointer group">
              <div className="h-12 w-12 bg-green-500/20 rounded-full flex items-center justify-center mb-4 group-hover:bg-green-500/40 transition-colors">
                <span className="text-green-500 font-bold text-xl">P</span>
              </div>
              <h3 className="text-xl font-semibold mb-2">Practice</h3>
              <p className="text-sm text-gray-500">Hone your skills with interactive exercises.</p>
            </div>
            <div className="p-6 bg-gray-800 rounded-xl border border-gray-700 hover:border-purple-500 transition-colors cursor-pointer group">
              <div className="h-12 w-12 bg-purple-500/20 rounded-full flex items-center justify-center mb-4 group-hover:bg-purple-500/40 transition-colors">
                <span className="text-purple-500 font-bold text-xl">S</span>
              </div>
              <h3 className="text-xl font-semibold mb-2">Stats</h3>
              <p className="text-sm text-gray-500">Track your progress and achievements.</p>
            </div>
          </div>
        </div>
      </main>
      <footer className="p-6 text-center text-gray-600 text-sm border-t border-gray-900">
        &copy; 2026 English Learning Platform. All rights reserved.
      </footer>
    </div>
  );
};

export default HomePage;
