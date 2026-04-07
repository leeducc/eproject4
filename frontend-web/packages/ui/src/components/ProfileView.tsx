import React, { useState, useEffect } from "react";
import { User, Mail, Shield, Camera, Lock, Save, Loader2, Phone, MapPin, Calendar, Info } from "lucide-react";
import { Button } from "./ui/button";
import { toast } from "./ui/toast";

export interface ProfileData {
    userId: number;
    email: string;
    role: string;
    fullName: string;
    avatarUrl?: string;
    bio?: string;
    address?: string;
    birthday?: string;
    phoneNumber?: string;
}

export interface ProfileViewProps {
    token: string;
    apiUrl: string;
    onUpdateSuccess?: () => void;
}

export function ProfileView({ token, apiUrl, onUpdateSuccess }: ProfileViewProps) {
    const [profile, setProfile] = useState<ProfileData | null>(null);
    const [loading, setLoading] = useState(true);
    const [updating, setUpdating] = useState(false);
    const [activeTab, setActiveTab] = useState<"info" | "password">("info");

    // Form states
    const [fullName, setFullName] = useState("");
    const [bio, setBio] = useState("");
    const [address, setAddress] = useState("");
    const [phoneNumber, setPhoneNumber] = useState("");
    const [birthday, setBirthday] = useState("");

    // Password states
    const [currentPassword, setCurrentPassword] = useState("");
    const [newPassword, setNewPassword] = useState("");
    const [confirmPassword, setConfirmPassword] = useState("");

    useEffect(() => {
        fetchProfile();
    }, []);

    const fetchProfile = async () => {
        try {
            console.log("[ProfileView] Fetching profile from", apiUrl);
            const response = await fetch(apiUrl, {
                headers: { 'Authorization': `Bearer ${token}` }
            });
            if (response.ok) {
                const data = await response.json();
                setProfile(data);
                setFullName(data.fullName || "");
                setBio(data.bio || "");
                setAddress(data.address || "");
                setPhoneNumber(data.phoneNumber || "");
                setBirthday(data.birthday || "");
            }
        } catch (err) {
            console.error("[ProfileView] Failed to fetch profile", err);
            toast.error("Failed to load profile data");
        } finally {
            setLoading(false);
        }
    };

    const handleUpdateProfile = async (e: React.FormEvent) => {
        e.preventDefault();
        setUpdating(true);
        console.log("[ProfileView] Updating profile info...");
        try {
            const response = await fetch(apiUrl, {
                method: "PUT",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": `Bearer ${token}`
                },
                body: JSON.stringify({
                    fullName,
                    bio,
                    address,
                    phoneNumber,
                    birthday,
                    avatarUrl: profile?.avatarUrl
                })
            });
            if (response.ok) {
                toast.success("Profile updated successfully");
                onUpdateSuccess?.();
                fetchProfile();
            } else {
                toast.error("Failed to update profile");
            }
        } catch (err) {
            console.error("[ProfileView] Update error", err);
            toast.error("An error occurred while updating profile");
        } finally {
            setUpdating(false);
        }
    };

    const handleChangePassword = async (e: React.FormEvent) => {
        e.preventDefault();
        if (newPassword !== confirmPassword) {
            toast.error("New passwords do not match");
            return;
        }

        setUpdating(true);
        console.log("[ProfileView] Changing password...");
        try {
            const response = await fetch(`${apiUrl}/change-password`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": `Bearer ${token}`
                },
                body: JSON.stringify({
                    currentPassword,
                    newPassword
                })
            });
            if (response.ok) {
                toast.success("Password updated successfully");
                setCurrentPassword("");
                setNewPassword("");
                setConfirmPassword("");
            } else {
                const error = await response.text();
                toast.error(error || "Failed to update password");
            }
        } catch (err) {
            console.error("[ProfileView] Password change error", err);
            toast.error("An error occurred while changing password");
        } finally {
            setUpdating(false);
        }
    };

    const handleAvatarUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        console.log("[ProfileView] Uploading new avatar...");
        const formData = new FormData();
        formData.append("file", file);
        formData.append("context", "avatar");

        try {
            setUpdating(true);
            const uploadResponse = await fetch("http://localhost:8123/api/media/upload", {
                method: "POST",
                headers: { "Authorization": `Bearer ${token}` },
                body: formData
            });

            if (uploadResponse.ok) {
                const mediaData = await uploadResponse.json();
                const avatarUrl = `http://localhost:8123${mediaData.storedPath}`;
                
                // Now update profile with new avatar URL
                const updateResponse = await fetch(apiUrl, {
                    method: "PUT",
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": `Bearer ${token}`
                    },
                    body: JSON.stringify({
                        ...profile,
                        avatarUrl
                    })
                });

                if (updateResponse.ok) {
                    toast.success("Avatar updated successfully");
                    fetchProfile();
                    onUpdateSuccess?.();
                }
            } else {
                toast.error("Failed to upload avatar");
            }
        } catch (err) {
            console.error("[ProfileView] Avatar upload error", err);
            toast.error("An error occurred during avatar upload");
        } finally {
            setUpdating(false);
        }
    };

    if (loading) {
        return (
            <div className="flex h-full items-center justify-center">
                <Loader2 className="w-8 h-8 animate-spin text-primary" />
            </div>
        );
    }

    return (
        <div className="max-w-4xl mx-auto space-y-8 animate-in fade-in duration-500">
            <div className="relative h-48 rounded-3xl bg-gradient-to-r from-primary/20 via-primary/5 to-secondary/20 border border-white/20 shadow-xl overflow-hidden">
                <div className="absolute inset-0 backdrop-blur-[2px]"></div>
                <div className="absolute -bottom-16 left-8 flex items-end gap-6 pb-20">
                    <div className="relative group">
                        <div className="w-32 h-32 rounded-3xl bg-white dark:bg-slate-800 border-4 border-white dark:border-slate-800 shadow-2xl overflow-hidden flex items-center justify-center">
                            {profile?.avatarUrl ? (
                                <img src={profile.avatarUrl} alt={profile.fullName} className="w-full h-full object-cover" />
                            ) : (
                                <div className="w-full h-full bg-orange-100 flex items-center justify-center text-4xl">
                                    🧑‍🏫
                                </div>
                            )}
                        </div>
                        <label className="absolute bottom-2 right-2 p-2 bg-primary text-white rounded-xl shadow-lg cursor-pointer hover:scale-110 transition-transform flex items-center justify-center">
                            <Camera size={18} />
                            <input type="file" className="hidden" accept="image/*" onChange={handleAvatarUpload} />
                        </label>
                    </div>
                    <div className="mb-2">
                        <h1 className="text-3xl font-bold text-gray-900 dark:text-white drop-shadow-sm">{profile?.fullName || "Your Profile"}</h1>
                        <p className="text-gray-600 dark:text-slate-400 font-medium flex items-center gap-2">
                            <Shield size={14} className="text-primary" />
                            {profile?.role}
                        </p>
                    </div>
                </div>
            </div>

            <div className="flex gap-4 p-1 bg-gray-100 dark:bg-slate-800/50 rounded-2xl w-fit border border-gray-200 dark:border-slate-700">
                <button 
                    onClick={() => setActiveTab("info")}
                    className={`px-6 py-2.5 rounded-xl text-sm font-semibold transition-all flex items-center gap-2 ${activeTab === 'info' ? 'bg-white dark:bg-slate-700 text-primary shadow-sm' : 'text-gray-500 hover:text-gray-700 dark:text-slate-400'}`}
                >
                    <Info size={16} /> Basic Info
                </button>
                <button 
                    onClick={() => setActiveTab("password")}
                    className={`px-6 py-2.5 rounded-xl text-sm font-semibold transition-all flex items-center gap-2 ${activeTab === 'password' ? 'bg-white dark:bg-slate-700 text-primary shadow-sm' : 'text-gray-500 hover:text-gray-700 dark:text-slate-400'}`}
                >
                    <Lock size={16} /> Security
                </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                <div className="md:col-span-2 space-y-6">
                    {activeTab === "info" ? (
                        <div className="bg-white/80 dark:bg-slate-900/80 backdrop-blur-xl border border-white dark:border-slate-800 rounded-3xl p-8 shadow-xl">
                            <form onSubmit={handleUpdateProfile} className="space-y-6">
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                    <div className="space-y-2">
                                        <label className="text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider ml-1">Full Name</label>
                                        <div className="relative group">
                                            <div className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-primary transition-colors">
                                                <User size={18} />
                                            </div>
                                            <input 
                                                value={fullName}
                                                onChange={(e) => setFullName(e.target.value)}
                                                className="w-full pl-12 pr-4 py-3 bg-gray-50 dark:bg-slate-800/50 border border-gray-100 dark:border-slate-700 rounded-2xl outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all text-gray-800 dark:text-slate-200"
                                                placeholder="Enter your full name"
                                            />
                                        </div>
                                    </div>
                                    <div className="space-y-2">
                                        <label className="text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider ml-1">Phone Number</label>
                                        <div className="relative group">
                                            <div className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-primary transition-colors">
                                                <Phone size={18} />
                                            </div>
                                            <input 
                                                value={phoneNumber}
                                                onChange={(e) => setPhoneNumber(e.target.value)}
                                                className="w-full pl-12 pr-4 py-3 bg-gray-50 dark:bg-slate-800/50 border border-gray-100 dark:border-slate-700 rounded-2xl outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all text-gray-800 dark:text-slate-200"
                                                placeholder="+84 123 456 789"
                                            />
                                        </div>
                                    </div>
                                    <div className="space-y-2">
                                        <label className="text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider ml-1">Birthday</label>
                                        <div className="relative group">
                                            <div className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-primary transition-colors">
                                                <Calendar size={18} />
                                            </div>
                                            <input 
                                                type="date"
                                                value={birthday}
                                                onChange={(e) => setBirthday(e.target.value)}
                                                className="w-full pl-12 pr-4 py-3 bg-gray-50 dark:bg-slate-800/50 border border-gray-100 dark:border-slate-700 rounded-2xl outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all text-gray-800 dark:text-slate-200"
                                            />
                                        </div>
                                    </div>
                                    <div className="space-y-2">
                                        <label className="text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider ml-1">Email (Immutable)</label>
                                        <div className="relative">
                                            <div className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-300 dark:text-slate-600">
                                                <Mail size={18} />
                                            </div>
                                            <input 
                                                value={profile?.email}
                                                disabled
                                                className="w-full pl-12 pr-4 py-3 bg-gray-100 dark:bg-slate-800/30 border border-gray-100 dark:border-slate-800 rounded-2xl text-gray-400 cursor-not-allowed"
                                            />
                                        </div>
                                    </div>
                                </div>

                                <div className="space-y-2">
                                    <label className="text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider ml-1">Address</label>
                                    <div className="relative group">
                                        <div className="absolute left-4 top-4 text-gray-400 group-focus-within:text-primary transition-colors">
                                            <MapPin size={18} />
                                        </div>
                                        <textarea 
                                            value={address}
                                            onChange={(e) => setAddress(e.target.value)}
                                            rows={2}
                                            className="w-full pl-12 pr-4 py-3 bg-gray-50 dark:bg-slate-800/50 border border-gray-100 dark:border-slate-700 rounded-2xl outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all text-gray-800 dark:text-slate-200 resize-none"
                                            placeholder="Your home or office address"
                                        />
                                    </div>
                                </div>

                                <div className="space-y-2">
                                    <label className="text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider ml-1">About Me</label>
                                    <textarea 
                                        value={bio}
                                        onChange={(e) => setBio(e.target.value)}
                                        rows={4}
                                        className="w-full px-4 py-3 bg-gray-50 dark:bg-slate-800/50 border border-gray-100 dark:border-slate-700 rounded-2xl outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all text-gray-800 dark:text-slate-200"
                                        placeholder="Tell us a little bit about yourself..."
                                    />
                                </div>

                                <div className="flex justify-end pt-4">
                                    <Button disabled={updating} type="submit" className="px-10 h-12 rounded-2xl font-bold gap-2">
                                        {updating ? <Loader2 size={18} className="animate-spin" /> : <Save size={18} />}
                                        Save Changes
                                    </Button>
                                </div>
                            </form>
                        </div>
                    ) : (
                        <div className="bg-white/80 dark:bg-slate-900/80 backdrop-blur-xl border border-white dark:border-slate-800 rounded-3xl p-8 shadow-xl">
                            <form onSubmit={handleChangePassword} className="space-y-6">
                                <div className="space-y-2">
                                    <label className="text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider ml-1">Current Password</label>
                                    <div className="relative group">
                                        <div className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-primary transition-colors">
                                            <Lock size={18} />
                                        </div>
                                        <input 
                                            type="password"
                                            value={currentPassword}
                                            onChange={(e) => setCurrentPassword(e.target.value)}
                                            className="w-full pl-12 pr-4 py-3 bg-gray-50 dark:bg-slate-800/50 border border-gray-100 dark:border-slate-700 rounded-2xl outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all text-gray-800 dark:text-slate-200"
                                            placeholder="••••••••"
                                        />
                                    </div>
                                </div>
                                <div className="space-y-2">
                                    <label className="text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider ml-1">New Password</label>
                                    <div className="relative group">
                                        <div className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-primary transition-colors">
                                            <Lock size={18} />
                                        </div>
                                        <input 
                                            type="password"
                                            value={newPassword}
                                            onChange={(e) => setNewPassword(e.target.value)}
                                            className="w-full pl-12 pr-4 py-3 bg-gray-50 dark:bg-slate-800/50 border border-gray-100 dark:border-slate-700 rounded-2xl outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all text-gray-800 dark:text-slate-200"
                                            placeholder="••••••••"
                                        />
                                    </div>
                                </div>
                                <div className="space-y-2">
                                    <label className="text-xs font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider ml-1">Confirm New Password</label>
                                    <div className="relative group">
                                        <div className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-primary transition-colors">
                                            <Lock size={18} />
                                        </div>
                                        <input 
                                            type="password"
                                            value={confirmPassword}
                                            onChange={(e) => setConfirmPassword(e.target.value)}
                                            className="w-full pl-12 pr-4 py-3 bg-gray-50 dark:bg-slate-800/50 border border-gray-100 dark:border-slate-700 rounded-2xl outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all text-gray-800 dark:text-slate-200"
                                            placeholder="••••••••"
                                        />
                                    </div>
                                </div>

                                <div className="flex justify-end pt-4">
                                    <Button disabled={updating} type="submit" className="px-10 h-12 rounded-2xl font-bold gap-2">
                                        {updating ? <Loader2 size={18} className="animate-spin" /> : <Shield size={18} />}
                                        Update Password
                                    </Button>
                                </div>
                            </form>
                        </div>
                    )}
                </div>

                <div className="space-y-6">
                    <div className="bg-gradient-to-br from-primary to-primary-focus rounded-3xl p-6 text-white shadow-xl">
                        <h3 className="text-xl font-bold mb-4">Complete Your Profile</h3>
                        <p className="text-white/80 text-sm mb-6">A complete profile helps you connect better with the team and students.</p>
                        <div className="space-y-4">
                            <div className="flex justify-between items-center text-sm">
                                <span>Profile Progress</span>
                                <span className="font-bold">75%</span>
                            </div>
                            <div className="h-2 bg-white/20 rounded-full overflow-hidden">
                                <div className="h-full bg-white w-3/4 rounded-full"></div>
                            </div>
                        </div>
                    </div>

                    <div className="bg-white/80 dark:bg-slate-900/80 backdrop-blur-xl border border-white dark:border-slate-800 rounded-3xl p-6 shadow-xl">
                        <h3 className="text-lg font-bold text-gray-800 dark:text-white mb-4">Quick Stats</h3>
                        <div className="space-y-4">
                            <div className="flex items-center gap-4">
                                <div className="w-10 h-10 rounded-xl bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center text-blue-600">
                                    <User size={18} />
                                </div>
                                <div>
                                    <p className="text-xs text-gray-500">Account ID</p>
                                    <p className="font-bold text-gray-800 dark:text-slate-200">#USER-{profile?.userId}</p>
                                </div>
                            </div>
                            <div className="flex items-center gap-4">
                                <div className="w-10 h-10 rounded-xl bg-green-100 dark:bg-green-900/30 flex items-center justify-center text-green-600">
                                    <Calendar size={18} />
                                </div>
                                <div>
                                    <p className="text-xs text-gray-500">Joined Since</p>
                                    <p className="font-bold text-gray-800 dark:text-slate-200">April 2024</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
