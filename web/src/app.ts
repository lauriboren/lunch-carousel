// Screen setup — a single full-window carousel, always the "basic lunch" list.

import { Carousel } from "./carousel";
import { basicRestaurants, CARD_ASPECT, CarouselConfig, pickConfig } from "./config";

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
  const logo = document.getElementById("logo") as HTMLElement;
  const carousel = new Carousel(carouselHost, pickConfig(window.innerWidth), basicRestaurants);

  // Place the logo centered in the gap above the cards. The perspective
  // magnifies the front card, so derive its apparent size to find the card top,
  // then center the logo between the viewport top and that edge.
  function positionLogo(config: CarouselConfig): void {
    const mag = config.depthScalar / (config.depthScalar - config.cardSpread);
    const apparentCardW = config.cardWidth * mag;
    const apparentCardH = config.cardWidth * CARD_ASPECT * mag;
    const cardTop = window.innerHeight / 2 - apparentCardH / 2;
    logo.style.top = `${cardTop / 2}px`;
    logo.style.width = `${apparentCardW * 0.4}px`;
  }

  positionLogo(pickConfig(window.innerWidth));

  let resizeRaf = 0;
  window.addEventListener("resize", () => {
    cancelAnimationFrame(resizeRaf);
    resizeRaf = requestAnimationFrame(() => {
      const config = pickConfig(window.innerWidth);
      carousel.applyConfig(config, carouselHost);
      positionLogo(config);
    });
  });
}
