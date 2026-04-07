import { Config } from "tailwindcss";

const config: Config = {
  darkMode: "class",
  content: [
    "./src/**/*.{js,ts,jsx,tsx}",
    "../../packages/ui/src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: "#6366f1", 
        "primary-light": "#818cf8",
        secondary: "#10b981", 
        accent: "#f43f5e", 
        "dashboard-bg": "#f8fafc", 
        "sidebar-inactive": "#64748b",
        "sidebar-active-bg": "#6366f1",
      },
    },
  },
  plugins: [],
};

export default config;
