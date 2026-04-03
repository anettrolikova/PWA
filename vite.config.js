import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  // For GitHub Pages deployment to https://anettrolikova.github.io/PWA/
  // Remove or set to '/' if deploying to a root domain (Vercel, custom domain)
  base: process.env.GITHUB_PAGES ? '/PWA/' : '/',
  plugins: [react()],
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
  },
  server: {
    port: 3000,
  },
});
