/// <reference types="vite/client" />
import axios from "axios";

export const apiClient = axios.create({
    baseURL: import.meta.env?.VITE_API_URL || "http://localhost:8123/api",
    headers: {
        "Content-Type": "application/json",
    },
});

// Automatically add interceptors for Auth here
apiClient.interceptors.request.use((config) => {
    const adminToken = localStorage.getItem("admin_token");
    const teacherToken = localStorage.getItem("teacher_token");
    const token = adminToken || teacherToken;

    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
        console.log(`[apiClient] Request authorized with ${adminToken ? 'admin' : 'teacher'} token`);
    } else {
        console.log("[apiClient] Request sent without token");
    }
    return config;
});
