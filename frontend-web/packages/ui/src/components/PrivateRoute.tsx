import { Navigate, Outlet } from "react-router-dom";
import { isTokenExpired, clearAuthTokens } from "@english-learning/api";

interface PrivateRouteProps {
    allowedRole: "ADMIN" | "TEACHER";
    redirectTo?: string;
}

export default function PrivateRoute({ allowedRole, redirectTo = "/login" }: PrivateRouteProps) {
    
    const tokenKey = allowedRole === "ADMIN" ? "admin_token" : "teacher_token";
    const token = localStorage.getItem(tokenKey);

    if (!token) {
        console.log(`[PrivateRoute] No token found for role ${allowedRole}, redirecting to ${redirectTo}`);
        return <Navigate to={redirectTo} replace />;
    }

    if (isTokenExpired(token)) {
        console.warn(`[PrivateRoute] Token for ${allowedRole} is expired detected during route transition.`);
        clearAuthTokens();
        return <Navigate to={redirectTo} replace />;
    }

    return <Outlet />;
}
