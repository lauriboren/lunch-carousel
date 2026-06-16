import { defineConfig } from "vite";
import { VitePWA } from "vite-plugin-pwa";

// `base: "./"` keeps asset paths relative so the build works from any
// subdirectory (GitHub Pages project site, a kiosk file:// load, etc.).
export default defineConfig({
  base: "./",
  plugins: [
    VitePWA({
      registerType: "autoUpdate",
      includeAssets: ["apple-touch-icon.png", "logo.png"],
      manifest: {
        name: "NYC Lunch Carousel",
        short_name: "LUNCH!",
        description: "Spin to pick a lunch spot near the NYC office.",
        start_url: "./",
        scope: "./",
        display: "standalone",
        orientation: "portrait",
        background_color: "#f5f5f5",
        theme_color: "#f5f5f5",
        icons: [
          { src: "pwa-192x192.png", sizes: "192x192", type: "image/png" },
          { src: "pwa-512x512.png", sizes: "512x512", type: "image/png" },
          {
            src: "maskable-512x512.png",
            sizes: "512x512",
            type: "image/png",
            purpose: "maskable",
          },
        ],
      },
      // Lets the manifest + service worker be tested via the dev server.
      devOptions: { enabled: true },
    }),
  ],
});
