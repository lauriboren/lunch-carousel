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

- 3D carousel: drag to spin, flick to fling with deceleration, snaps to the nearest card
- Arbitrary-length restaurant lists mapped onto 8 physical cards (neighbor-inference algorithm)
- BASIC LUNCH / NICE LUNCH™ toggle with an animated underline
- Tap the title to cycle 4 themes (white / black / beige / green) with a cross-dissolve
- Responsive: iPad-sized geometry on wide screens, phone-sized below 768px

## Scope notes

This is the core MVP. Intentionally **not** ported from the iOS app:

- **Audio** — the per-card click sound.
- **Easter eggs** — the 🦞 lobster animation and the US-holiday "Burger & Lobster
  day" detection. These were already dormant (disabled) in the iOS app.

The title uses a **system serif stack** instead of the iOS app's PPEditorialNew,
which is a commercial font. Cards use Inter (open-licensed), bundled in
`public/fonts/`. `Carousel.spinTo()` is kept as public API in case the lobster
easter egg is added later.

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
