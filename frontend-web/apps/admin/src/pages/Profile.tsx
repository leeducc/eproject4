import { AdminLayout } from "../components/AdminLayout";
import { ProfileView } from "@english-learning/ui";

export default function ProfilePage() {
    const token = localStorage.getItem("admin_token") || "";
    const apiUrl = "http://localhost:8123/api/profile";

    return (
        <AdminLayout>
            <div className="py-6">
                <ProfileView 
                    token={token} 
                    apiUrl={apiUrl} 
                    onUpdateSuccess={() => {
                        console.log("[Admin Profile] Profile updated, reloading...");
                        window.location.reload();
                    }}
                />
            </div>
        </AdminLayout>
    );
}
