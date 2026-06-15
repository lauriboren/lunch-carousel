// Screen setup — a single full-window carousel, always the "basic lunch" list.

import { Carousel } from "./carousel";
import { basicRestaurants, pickConfig } from "./config";

export function initApp(): void {
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
