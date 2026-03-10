import { Config } from "tailwindcss";

const config: Config = {
  content: [
    "../../apps/*/src/**/*.{js,ts,jsx,tsx}",
    "../../packages/ui/src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: "#6366f1", // Indigo 500 equivalent from screenshot
        "primary-light": "#818cf8",
        secondary: "#10b981", // Emerald for the green cards
        accent: "#f43f5e", // Rose for the red cards
        "dashboard-bg": "#f8fafc", // Very light slate/gray for background
        "sidebar-inactive": "#64748b",
        "sidebar-active-bg": "#6366f1",
      },
    },
  },
  plugins: [],
};

export default config;
