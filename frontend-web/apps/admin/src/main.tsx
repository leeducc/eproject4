import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import './index.css'
import { ThemeProvider, ErrorBoundary } from '@english-learning/ui'

ReactDOM.createRoot(document.getElementById('root')!).render(
    <React.StrictMode>
        <ErrorBoundary>
            <ThemeProvider defaultTheme="light" storageKey="admin-ui-theme">
                <App />
            </ThemeProvider>
        </ErrorBoundary>
    </React.StrictMode>,
)
