import React, { useState } from 'react';

interface LoginPageProps {
  onLogin: () => void;
}

const LoginPage: React.FC<LoginPageProps> = ({ onLogin }) => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const validate = () => {
    if (!username.trim()) return 'Username is required';
    if (!password) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$/.test(password)) {
      return 'Password must include uppercase, lowercase, and numbers';
    }
    return '';
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    const validationError = validate();
    if (validationError) {
      setError(validationError);
      return;
    }

    console.log('Login attempt for user:', username);
    onLogin();
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-slate-50 dark:bg-gray-950 text-slate-900 dark:text-white p-4 transition-colors duration-300">
      <div className="w-full max-w-md bg-white dark:bg-gray-800 p-8 rounded-lg shadow-xl border border-slate-200 dark:border-gray-700 transition-colors duration-300">
        <h1 className="text-3xl font-bold mb-6 text-center bg-gradient-to-r from-blue-400 to-purple-500 bg-clip-text text-transparent">
          Customer Login
        </h1>
        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label className="block text-sm font-medium mb-2 opacity-80">Username</label>
            <input
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className="w-full p-3 rounded bg-slate-100 dark:bg-gray-700 border border-slate-200 dark:border-gray-600 focus:border-blue-500 outline-none transition-colors dark:text-white"
              placeholder="Enter your username"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-2 opacity-80">Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full p-3 rounded bg-slate-100 dark:bg-gray-700 border border-slate-200 dark:border-gray-600 focus:border-blue-500 outline-none transition-colors dark:text-white"
              placeholder="Enter your password"
            />
          </div>
          {error && (
            <div className="p-3 text-sm text-red-500 bg-red-500/10 border border-red-500/20 rounded">
              {error}
            </div>
          )}
          <button
            type="submit"
            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 rounded transition-all transform hover:scale-105 active:scale-95 shadow-lg"
          >
            Sign In
          </button>
          <button
            type="button"
            onClick={() => {
              setUsername('user1@gmail.com');
              setPassword('User@123');
              console.log('Quick login credentials filled');
            }}
            className="w-full bg-slate-200 dark:bg-gray-700 hover:bg-slate-300 dark:hover:bg-gray-600 text-slate-700 dark:text-white font-semibold py-2 rounded transition-all border border-slate-300 dark:border-gray-600 mt-2"
          >
            Quick Login (Demo)
          </button>
        </form>
      </div>
    </div>
  );
};

export default LoginPage;
