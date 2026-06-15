// Restaurant lists, themes, and carousel tuning — ported from iOS Config.swift.

export const basicRestaurants = [
  "Summer Salt",
  "Bombay Sandwich",
  "Glur",
  "Daily Provisions",
  "Oramen",
  "Thai Vila",
  "Taïm",
  "Little Beet",
  "Inday",
  "Tappo",
  "Zero Otto Nove",
  "Milu",
  "Sugarfish",
  "Sushi Burrito Yummy Stick",
  "Naya",
  "Hole In The Wall",
  "Burger & Lobster",
];

export const niceRestaurants = [
  "Casa Mono",
  "Pranakhon",
  "Boucherie",
  "Rezdôra",
  "SUGARFISH",
  "Gramercy Tavern",
  "L’Express",
  "ilili",
  "Excellent Dumpling House",
];

export interface Theme {
  screenBg: string;
  titleColor: string;
  toggleSelected: string;
  toggleDeselected: string;
  cardBg: string;
  cardText: string;
}

// Order matches the iOS `themes` array: white, black, beige, green.
export const themes: Theme[] = [
  {
    screenBg: "#F5F5F5",
    titleColor: "#000000",
    toggleSelected: "#000000",
    toggleDeselected: "#666666",
    cardBg: "#FFFFFF",
    cardText: "#000000",
  },
  {
    screenBg: "#111111",
    titleColor: "#FFFFFF",
    toggleSelected: "#FFFFFF",
    toggleDeselected: "#666666",
    cardBg: "#303030",
    cardText: "#FFFFFF",
  },
  {
    screenBg: "#E7E2D2",
    titleColor: "#676459",
    toggleSelected: "#676459",
    toggleDeselected: "#999999",
    cardBg: "#F8F4E7",
    cardText: "#56534A",
  },
  {
    screenBg: "#005221",
    titleColor: "#00A341",
    toggleSelected: "#00E95D",
    toggleDeselected: "#00A341",
    cardBg: "#00A341",
    cardText: "#FFFFFF",
  },
];

export interface CarouselConfig {
  cardWidth: number;
  cardHeight: number;
  cardCornerRadius: number;
  cardPadding: number;
  /** Larger = cards further from the viewer (maps to CSS `perspective`). */
  depthScalar: number;
  /** Larger = cards spread further apart (maps to per-card `translateZ`). */
  cardSpread: number;
  /** Velocity multiplier per frame while decelerating. 1 = forever, 0 = instant stop. */
  decelerationScalar: number;
  /** Snap-to-card animation duration, in seconds. */
  snapDuration: number;
  /** fontSize = cardWidth * this ratio. */
  cardFontSizeToCardWidthRatio: number;
}

const configIpad: CarouselConfig = {
  cardWidth: 307,
  cardHeight: 412,
  cardCornerRadius: 12,
  cardPadding: 40,
  depthScalar: 2400,
  cardSpread: 445,
  decelerationScalar: 0.98,
  snapDuration: 0.4,
  cardFontSizeToCardWidthRatio: 0.08,
};

const configPhone: CarouselConfig = {
  cardWidth: 168,
  cardHeight: 288,
  cardCornerRadius: 12,
  cardPadding: 24,
  depthScalar: 700,
  cardSpread: 240,
  decelerationScalar: 0.96,
  snapDuration: 0.3,
  cardFontSizeToCardWidthRatio: 0.08,
};

/** Pick a carousel config based on viewport width, mirroring the iPad/iPhone split. */
export function pickConfig(viewportWidth: number): CarouselConfig {
  return viewportWidth >= 768 ? configIpad : configPhone;
}
