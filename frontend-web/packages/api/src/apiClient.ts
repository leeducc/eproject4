import axios from "axios";
import { clearAuthTokens, isTokenExpired } from "./authUtils";

export const apiClient = axios.create({
    baseURL: import.meta.env?.VITE_API_URL || "http://localhost:8123/api",
    headers: {
        "Content-Type": "application/json",
    },
});


apiClient.interceptors.request.use((config) => {
    const adminToken = localStorage.getItem("admin_token");
    const teacherToken = localStorage.getItem("teacher_token");
    const token = adminToken || teacherToken;

    if (token) {
        if (isTokenExpired(token)) {
            console.warn("[apiClient] Token expired detected in request interceptor. Logging out User.");
            clearAuthTokens();
            return Promise.reject(new Error("Token expired"));
        }
        config.headers.Authorization = `Bearer ${token}`;
        console.log(`[apiClient] Request authorized with ${adminToken ? 'admin' : 'teacher'} token`);
    } else {
        console.log("[apiClient] Request sent without token");
    }
    return config;
});


apiClient.interceptors.response.use(
    (response) => {
        return response;
    },
    (error) => {
        if (error.response && (error.response.status === 401)) {
            console.warn("[apiClient] 401 Unauthorized detected. Clearing session and redirecting to login.");
            clearAuthTokens();
        }
        return Promise.reject(error);
    }
);
