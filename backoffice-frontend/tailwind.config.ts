/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: {
          500: '#f97316',
          600: '#ea580c',
        },
        sidebar: '#1e293b',
      },
    },
  },
  plugins: [],
};
