import { defineConfig } from "vite";

// `base: "./"` keeps asset paths relative so the static build works from any
// subdirectory (GitHub Pages, a kiosk file:// load, etc.) without extra config.
export default defineConfig({
  base: "./",
});
