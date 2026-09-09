// @ts-check
import { defineConfig } from 'astro/config';

import vue from '@astrojs/vue';
import AstroPWA from '@vite-pwa/astro';

export default defineConfig({
  site: 'https://yaperson.github.io',
  base: '/procedures/',
  integrations: [
    vue(),
    AstroPWA({
      registerType: 'autoUpdate',
      manifest: {
        name: 'Procédures PWA',
        short_name: 'Procédures',
        description: 'Application de gestion des procédures',
        theme_color: '#ffffff',
        icons: [
          {
            src: 'pwa-192x192.png',
            sizes: '192x192',
            type: 'image/png'
          },
          {
            src: 'pwa-512x512.png',
            sizes: '512x512',
            type: 'image/png'
          }
        ]
      },
      workbox: {
        navigateFallback: '/procedures/index.html',
        globPatterns: ['**/*.{js,css,html,svg,png,jpg,jpeg,gif,webp,woff,woff2,ttf,eot,ico}'],
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/.*\.supabase\.co\/.*/i,
            handler: 'NetworkFirst',
            options: {
              cacheName: 'supabase-api-cache',
              expiration: {
                maxEntries: 100,
                maxAgeSeconds: 60 * 60 * 24 * 7 // 1 week
              },
              cacheableResponse: {
                statuses: [0, 200]
              }
            }
          }
        ]
      }
    })
  ]
});