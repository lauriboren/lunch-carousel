// Screen chrome — title + theme cycling. The carousel is always "basic lunch".
// Ported from iOS ViewController.swift (MVP subset: no audio, no easter eggs).

import { Carousel } from "./carousel";
import { basicRestaurants, pickConfig, themes, Theme } from "./config";

export function initApp(): void {
  const root = document.documentElement;
  const titleEl = document.getElementById("title") as HTMLElement;
  const carouselHost = document.getElementById("carousel") as HTMLElement;

  let themeIndex = 0;

  const carousel = new Carousel(carouselHost, pickConfig(window.innerWidth), basicRestaurants);

  function applyTheme(theme: Theme): void {
    root.style.setProperty("--screen-bg", theme.screenBg);
    root.style.setProperty("--title-color", theme.titleColor);
    root.style.setProperty("--card-bg", theme.cardBg);
    root.style.setProperty("--card-text", theme.cardText);
  }

  titleEl.addEventListener("click", () => {
    themeIndex = (themeIndex + 1) % themes.length;
    applyTheme(themes[themeIndex]);
  });

  let resizeRaf = 0;
  window.addEventListener("resize", () => {
    cancelAnimationFrame(resizeRaf);
    resizeRaf = requestAnimationFrame(() => {
      carousel.applyConfig(pickConfig(window.innerWidth), carouselHost);
    });
  });

  applyTheme(themes[themeIndex]);
}
