import { Navigate, Outlet } from "react-router-dom";

interface PrivateRouteProps {
    allowedRole: "ADMIN" | "TEACHER";
    redirectTo?: string;
}

export default function PrivateRoute({ allowedRole, redirectTo = "/login" }: PrivateRouteProps) {
    // In a real app, decode the JWT to check roles and validity
    const tokenKey = allowedRole === "ADMIN" ? "admin_token" : "teacher_token";
    const token = localStorage.getItem(tokenKey);

    if (!token) {
        console.log(`[PrivateRoute] No token found for role ${allowedRole}, redirecting to ${redirectTo}`);
        return <Navigate to={redirectTo} replace />;
    }

    return <Outlet />;
}
