import { TeacherLayout } from "../components/TeacherLayout";
import { ProfileView } from "@english-learning/ui";

export default function ProfilePage() {
    const token = localStorage.getItem("teacher_token") || "";
    const apiUrl = "http://localhost:8123/api/profile";

    return (
        <TeacherLayout>
            <div className="py-6">
                <ProfileView 
                    token={token} 
                    apiUrl={apiUrl} 
                    onUpdateSuccess={() => {
                        console.log("[Teacher Profile] Profile updated, reloading...");
                        window.location.reload(); 
                    }}
                />
            </div>
        </TeacherLayout>
    );
}
