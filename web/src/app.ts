// Screen chrome — title, theme cycling, and the lunch-type toggle.
// Ported from iOS ViewController.swift (the MVP subset: no audio, no easter eggs).

import { Carousel } from "./carousel";
import { basicRestaurants, niceRestaurants, pickConfig, themes, Theme } from "./config";

type LunchType = "basic" | "nice";

export function initApp(): void {
  const root = document.documentElement;
  const titleEl = document.getElementById("title") as HTMLElement;
  const basicBtn = document.getElementById("basic") as HTMLButtonElement;
  const niceBtn = document.getElementById("nice") as HTMLButtonElement;
  const underline = document.getElementById("underline") as HTMLElement;
  const carouselHost = document.getElementById("carousel") as HTMLElement;

  let themeIndex = 0;
  let lunchType: LunchType = "basic";

  const carousel = new Carousel(carouselHost, pickConfig(window.innerWidth), basicRestaurants);

  function applyTheme(theme: Theme): void {
    root.style.setProperty("--screen-bg", theme.screenBg);
    root.style.setProperty("--title-color", theme.titleColor);
    root.style.setProperty("--toggle-selected", theme.toggleSelected);
    root.style.setProperty("--toggle-deselected", theme.toggleDeselected);
    root.style.setProperty("--card-bg", theme.cardBg);
    root.style.setProperty("--card-text", theme.cardText);
  }

  // Move the underline beneath whichever button is active, scaling its width
  // to match. transform-origin is the left edge so translate + scaleX compose.
  function positionUnderline(): void {
    const target = lunchType === "basic" ? basicBtn : niceBtn;
    const dx = target.offsetLeft - basicBtn.offsetLeft;
    const scale = target.offsetWidth / basicBtn.offsetWidth;
    underline.style.left = `${basicBtn.offsetLeft}px`;
    underline.style.top = `${basicBtn.offsetTop + basicBtn.offsetHeight - 6}px`;
    underline.style.width = `${basicBtn.offsetWidth}px`;
    underline.style.transform = `translateX(${dx}px) scaleX(${scale})`;
  }

  function setLunchType(type: LunchType): void {
    lunchType = type;
    basicBtn.classList.toggle("is-selected", type === "basic");
    niceBtn.classList.toggle("is-selected", type === "nice");
    carousel.setRestaurants(type === "basic" ? basicRestaurants : niceRestaurants);
    positionUnderline();
  }

  titleEl.addEventListener("click", () => {
    themeIndex = (themeIndex + 1) % themes.length;
    applyTheme(themes[themeIndex]);
  });

  basicBtn.addEventListener("click", () => setLunchType("basic"));
  niceBtn.addEventListener("click", () => setLunchType("nice"));

  let resizeRaf = 0;
  window.addEventListener("resize", () => {
    cancelAnimationFrame(resizeRaf);
    resizeRaf = requestAnimationFrame(() => {
      carousel.applyConfig(pickConfig(window.innerWidth), carouselHost);
      positionUnderline();
    });
  });

  applyTheme(themes[themeIndex]);
  positionUnderline();
}
