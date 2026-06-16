// Restaurant lists, themes, and carousel tuning — ported from iOS Config.swift.

export interface Restaurant {
  name: string;
  /** Street address shown under the name. Empty string hides the line. */
  address: string;
  /** Walking time in minutes; rendered as "(N minute walk)". 0 hides the line. */
  walkMinutes: number;
}

export const basicRestaurants: Restaurant[] = [
  { name: "Revelie", address: "179 Prince Street", walkMinutes: 4 },
  { name: "ALIDORO", address: "105 Sullivan Street", walkMinutes: 6 },
  { name: "Pi Bakerie", address: "512 Broome Street", walkMinutes: 6 },
  { name: "Lucia Alimentari", address: "301 West Broadway", walkMinutes: 9 },
  { name: "Le Botaniste", address: "127 Grand Street", walkMinutes: 9 },
  { name: "Dig Inn", address: "70 Prince Street", walkMinutes: 4 },
  { name: "Fanelli Café", address: "94 Prince Street", walkMinutes: 2 },
  { name: "Olive’s", address: "191 Prince Street", walkMinutes: 5 },
  { name: "Court Street Grocers", address: "540 LaGuardia Place", walkMinutes: 9 },
  { name: "Hamburger America", address: "155 West Houston Street", walkMinutes: 8 },
  { name: "Dante NYC", address: "79-81 MacDougal Street", walkMinutes: 10 },
  { name: "THISBOWL", address: "65 Bleecker Street", walkMinutes: 9 },
  { name: "5ive Spice", address: "227 Mulberry Street", walkMinutes: 7 },
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

/** Card height / width. Fixed at 3:4 (360x480) so proportions match at every size. */
export const CARD_ASPECT = 480 / 360;

export interface CarouselConfig {
  cardWidth: number;
  // Card height is derived from cardWidth via CARD_ASPECT (a fixed 3:4 / 360x480
  // ratio) so proportions stay identical across screen sizes.
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
  cardCornerRadius: 12,
  cardPadding: 40,
  depthScalar: 2400,
  cardSpread: 445,
  decelerationScalar: 0.98,
  snapDuration: 0.4,
  cardFontSizeToCardWidthRatio: 36 / 307, // name = 36px on the 307px card, scaled by width
};

const configPhone: CarouselConfig = {
  // The perspective magnifies the front card ~1.52x, so a 210px element renders
  // ~320px wide on screen — i.e. apparent 320x427 with ~37px side margins on a
  // 393px phone. (Sizing the element to a literal 320 overflows the screen.)
  cardWidth: 245,
  cardCornerRadius: 12,
  cardPadding: 26,
  depthScalar: 1333,
  cardSpread: 314,
  decelerationScalar: 0.96,
  snapDuration: 0.3,
  cardFontSizeToCardWidthRatio: 0.075, // apparent name ≈ 24px (24/320)
};

/** Pick a carousel config based on viewport width, mirroring the iPad/iPhone split. */
export function pickConfig(viewportWidth: number): CarouselConfig {
  return viewportWidth >= 768 ? configIpad : configPhone;
}
