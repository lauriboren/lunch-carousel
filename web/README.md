# NYC Lunch Carousel — Web

A lightweight web port of the iOS Lunch Carousel app. The 3D spinning wheel is
built with plain CSS 3D transforms (no canvas / WebGL) driven by a
`requestAnimationFrame` loop — no UI framework.

## Stack

- **Vite + TypeScript**, vanilla DOM
- CSS 3D transforms (`perspective` + `rotateY`/`translateZ`, `backface-visibility`)
- Pointer Events for drag / flick

## Run

```bash
npm install
npm run dev      # dev server at http://localhost:5173
npm run build    # typecheck + static build into dist/
npm run preview  # serve the production build
```

`dist/` is fully static — deploy to GitHub Pages, Netlify, Vercel, or any static host.

## Features

- Full-window 3D carousel, vertically centered: drag to spin, flick to fling with
  deceleration, snaps to the nearest card
- Each card shows the restaurant **name, address, and walking time** ("N minute walk")
- Arbitrary-length restaurant lists mapped onto 8 physical cards (neighbor-inference algorithm)
- Responsive: iPad-sized geometry on wide screens, phone-sized below 768px

Restaurants live in [`src/config.ts`](src/config.ts) as `{ name, address, walkMinutes }`.
Address/walk lines auto-hide for any entry left without that data.

## Scope notes

This is the core MVP. Intentionally **not** ported from the iOS app:

- **Audio** — the per-card click sound.
- **Easter eggs** — the 🦞 lobster animation and the US-holiday "Burger & Lobster
  day" detection. These were already dormant (disabled) in the iOS app.
- **Lunch-type toggle, theme switching, and the heading** — present early on, then
  removed in favor of a single clean carousel.

Cards use Inter (open-licensed), bundled in `public/fonts/`. `Carousel.spinTo()` is
kept as public API in case the lobster easter egg is added later.

## Mapping from iOS

| iOS (Core Animation) | Web |
| --- | --- |
| `CADisplayLink` loop | `requestAnimationFrame` |
| `CATransformLayer` | `<div>` with `transform-style: preserve-3d` |
| `transform.m34 = -1/depthScalar` | `perspective` on the host |
| `rotateY` + `translateZ` | per-card CSS transform |
| `isDoubleSided = false` | `backface-visibility: hidden` |
| `touchesBegan/Moved/Ended` | Pointer Events |
| Theme config structs | CSS custom properties |
