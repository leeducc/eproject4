import { useEffect } from "react";

export const clearAuthTokens = () => {
    console.log("[authUtils] Clearing tokens and redirecting to login");
    localStorage.removeItem("admin_token");
    localStorage.removeItem("teacher_token");
    localStorage.removeItem("teacher_user");
    localStorage.removeItem("admin_user");
    
    if (window.location.pathname !== "/login") {
        window.location.href = "/login";
    }
};

export const isTokenExpired = (token: string): boolean => {
    try {
        const payloadBase64 = token.split(".")[1];
        if (!payloadBase64) return true;
        
        const payload = JSON.parse(atob(payloadBase64));
        const currentTime = Math.floor(Date.now() / 1000);
        
        const expired = payload.exp < currentTime;
        if (expired) {
            console.log("[authUtils] Token is expired. Payload exp:", payload.exp, "Current:", currentTime);
        }
        return expired;
    } catch (e) {
        console.error("[authUtils] Error checking token expiration:", e);
        return true; 
    }
};

/**
 * Hook to automatically log out when token expires even if the user does not take any action.
 */
export const useAutoLogout = (token: string | null) => {
    useEffect(() => {
        if (!token) return;

        try {
            const payloadBase64 = token.split(".")[1];
            if (!payloadBase64) return;
            
            const payload = JSON.parse(atob(payloadBase64));
            const expiresAtMs = payload.exp * 1000;
            const delay = expiresAtMs - Date.now();

            if (delay <= 0) {
                console.warn("[useAutoLogout] Token already expired. Logging out now.");
                clearAuthTokens();
                return;
            }

            console.log(`[useAutoLogout] Setting logout timer for ${Math.floor(delay / 1000)} seconds.`);
            const timer = setTimeout(() => {
                console.warn("[useAutoLogout] Token expired in background. Automated logout triggered.");
                clearAuthTokens();
            }, delay);

            return () => clearTimeout(timer);
        } catch (e) {
            console.error("[useAutoLogout] Failed to set auto-logout timer:", e);
        }
    }, [token]);
};
