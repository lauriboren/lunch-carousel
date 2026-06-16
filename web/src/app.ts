// Screen setup — a single full-window carousel, always the "basic lunch" list.

import { Carousel } from "./carousel";
import { basicRestaurants, pickConfig } from "./config";

export function initApp(): void {
  // iOS Safari ignores user-scalable=no, so block its pinch-zoom gesture events
  // and double-tap-to-zoom explicitly.
  for (const evt of ["gesturestart", "gesturechange", "gestureend"]) {
    document.addEventListener(evt, (e) => e.preventDefault(), { passive: false });
  }
  let lastTouchEnd = 0;
  document.addEventListener(
    "touchend",
    (e) => {
      const now = Date.now();
      if (now - lastTouchEnd < 300) e.preventDefault(); // kill double-tap zoom
      lastTouchEnd = now;
    },
    { passive: false }
  );

  const carouselHost = document.getElementById("carousel") as HTMLElement;
  const carousel = new Carousel(carouselHost, pickConfig(window.innerWidth), basicRestaurants);

  let resizeRaf = 0;
  window.addEventListener("resize", () => {
    cancelAnimationFrame(resizeRaf);
    resizeRaf = requestAnimationFrame(() => {
      carousel.applyConfig(pickConfig(window.innerWidth), carouselHost);
    });
  });
}
