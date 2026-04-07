import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { apiClient } from "@english-learning/api";
import { useAuth } from "../context/AuthContext";

export default function TeacherLogin() {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");
    const [isLoading, setIsLoading] = useState(false);
    const navigate = useNavigate();
    const { login } = useAuth();

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setError("");

        
        if (!email || !password) {
            setError("Email and Password are required.");
            return;
        }
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            setError("Please enter a valid email address.");
            return;
        }

        setIsLoading(true);
        try {
            const response = await apiClient.post("/auth/login", {
                email,
                password,
                role: "TEACHER"
            });

            const { token, id, role, fullName, email: userEmail } = response.data;
            login(token, { id, role, name: fullName || "Teacher User", email: userEmail || email });
            navigate("/teacher/dashboard");
        } catch (err: any) {
            setError(err.response?.data?.error || err.response?.data?.message || "Invalid credentials. Please try again.");
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-[#f4f7f9]">
            <div className="bg-white p-10 rounded-3xl shadow-[0_4px_24px_rgba(0,0,0,0.05)] w-full max-w-md border border-gray-100">
                <h1 className="text-3xl font-semibold text-center text-gray-800 mb-2">Teacher Portal Login</h1>
                <p className="text-center text-sm text-gray-600 font-medium mb-8">
                    Enter <span className="text-black font-semibold">Account Email Address</span> and <span className="text-black font-semibold">Password</span>
                </p>

                {error && (
                    <div className="bg-red-50 text-red-500 text-sm p-3 rounded mb-4 text-center">
                        {error}
                    </div>
                )}

                <form onSubmit={handleLogin} className="space-y-4">
                    <div>
                        <input
                            type="text"
                            placeholder="Enter Email Address"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            className="w-full px-4 py-3 bg-[#f3f7fa] border border-[#e4ecf2] rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-700 placeholder-gray-400"
                        />
                    </div>
                    <div>
                        <div className="relative">
                            <input
                                type="password"
                                placeholder="Enter Password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                className="w-full px-4 py-3 bg-[#f3f7fa] border border-[#e4ecf2] rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-700 placeholder-gray-400"
                            />
                            <span className="absolute right-4 top-3 text-gray-400">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                                    <path fillRule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clipRule="evenodd" />
                                </svg>
                            </span>
                        </div>
                    </div>

                    <button
                        type="submit"
                        disabled={isLoading}
                        className="w-full bg-[#1b5fcc] hover:bg-[#1650b0] text-white font-semibold py-3 rounded-md transition duration-200 mt-2 disabled:opacity-70"
                    >
                        {isLoading ? "Logging In..." : "Log In Now"}
                    </button>
                    <button
                        type="button"
                        onClick={() => {
                            setEmail("teacher1@gmail.com");
                            setPassword("Teacher@123");
                            console.log("Teacher quick login credentials filled");
                        }}
                        className="w-full bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold py-2 rounded-md transition duration-200 mt-2 border border-gray-200"
                    >
                        Quick Login (Teacher)
                    </button>
                </form>
            </div>
        </div>
    );
}
