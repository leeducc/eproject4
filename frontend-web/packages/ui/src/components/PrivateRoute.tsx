import { Navigate, Outlet } from "react-router-dom";

interface PrivateRouteProps {
    allowedRole: "ADMIN" | "TEACHER";
}

export default function PrivateRoute({ allowedRole }: PrivateRouteProps) {
    // In a real app, decode the JWT to check roles and validity
    const tokenKey = allowedRole === "ADMIN" ? "admin_token" : "teacher_token";
    const token = localStorage.getItem(tokenKey);

    if (!token) {
        return <Navigate to="/" replace />;
    }

    return <Outlet />;
}
