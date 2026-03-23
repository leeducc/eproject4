import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import LoginPage from './pages/LoginPage';
import HomePage from './pages/HomePage';
import { useState, useEffect } from 'react';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(
    localStorage.getItem('customer_auth') === 'true'
  );

  useEffect(() => {
    console.log('Auth state changed:', isAuthenticated);
  }, [isAuthenticated]);

  const handleLogin = () => {
    console.log('Handling login...');
    localStorage.setItem('customer_auth', 'true');
    setIsAuthenticated(true);
  };

  const handleLogout = () => {
    console.log('Handling logout...');
    localStorage.removeItem('customer_auth');
    setIsAuthenticated(false);
  };

  return (
    <BrowserRouter>
      <Routes>
        <Route 
          path="/login" 
          element={
            isAuthenticated ? <Navigate to="/" /> : <LoginPage onLogin={handleLogin} />
          } 
        />
        <Route 
          path="/" 
          element={
            isAuthenticated ? <HomePage onLogout={handleLogout} /> : <Navigate to="/login" />
          } 
        />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
