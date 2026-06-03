import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'
import path from 'path'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  build: {
    outDir: 'C:/Users/locth/source/repos/DOAN4/DOAN4/wwwroot',
    emptyOutDir: false,
  },
  server: {
    proxy: {
     
      '/api': {
        target: 'https://localhost:7126',
        changeOrigin: true,
        secure: false, 
      },
      
      '/images': {
        target: 'https://localhost:7126',
        changeOrigin: true,
        secure: false,
      },
      
      '/uploads': {
        target: 'https://localhost:7126',
        changeOrigin: true,
        secure: false,
      }
    }
  }
})
