// 3D carousel — a web port of iOS CarouselView.swift.
//
// 8 physical cards are arranged in a circle and perspective-projected. An
// arbitrary-length restaurant list is mapped onto the visible cards as the wheel
// spins, using the same neighbor-inference algorithm as the original app.
//
// iOS -> web mapping:
//   CADisplayLink update loop      -> requestAnimationFrame
//   CATransformLayer (parent)      -> a <div> with `transform-style: preserve-3d`
//   transform.m34 = -1/depthScalar -> CSS `perspective` on the host
//   rotateY + translateZ           -> per-card CSS transform
//   isDoubleSided = false          -> `backface-visibility: hidden`
//   touchesBegan/Moved/Ended       -> Pointer Events

import { CarouselConfig } from "./config";
import { easeInOutSine, easeOutCirc, normalizeAngle } from "./math";

const NUM_CARDS = 8;
const SEGMENT = 360 / NUM_CARDS; // 45 degrees

// Drag/fling tuning, kept identical to the iOS values for matching feel.
const TOUCH_DELTA_TO_ANGLE = 0.12; // px of finger travel -> degrees, while dragging
const FLING_SCALAR = 0.4; // px/sec -> degrees/sec, on release
const MIN_FLING_PX = 2; // ignore touches that barely moved
const MIN_VELOCITY = 5; // below this we stop and snap

type State = "idle" | "dragging" | "snapping" | "decelerating";

type EaseFn = (x: number) => number;

const now = () => performance.now() / 1000; // seconds, matching CACurrentMediaTime

export class Carousel {
  private stage: HTMLElement;
  private cards: HTMLElement[] = [];
  private textEls: HTMLElement[] = [];

  private restaurants: string[];
  private config: CarouselConfig;

  private currentAngle = 0;
  private prevDrawnAngle = -1;
  private state: State = "idle";

  // Fling deceleration
  private velocity = 0;
  private prevDecelTime = 0;

  // Snap-to-card animation
  private snapStartTime = 0;
  private snapStartAngle = 0;
  private snapTargetAngle = 0;
  private snapDuration = 0;
  private snapEase: EaseFn = easeInOutSine;

  // Pointer drag
  private dragging = false;
  private lastX = 0;
  private pointerId: number | null = null;
  private history: { t: number; x: number }[] = [];

  private cardCenterAngles: number[] = [];
  // Maps a visible card index -> the restaurant index currently shown on it.
  private visibleCardToRestaurant = new Map<number, number>();

  /** Fired when the wheel settles on a restaurant. */
  onChoose?: (restaurant: string) => void;

  constructor(host: HTMLElement, config: CarouselConfig, restaurants: string[]) {
    this.config = config;
    this.restaurants = restaurants;

    host.classList.add("carousel-host");
    host.style.touchAction = "none"; // we handle dragging ourselves

    this.stage = document.createElement("div");
    this.stage.className = "carousel-stage";
    host.appendChild(this.stage);

    for (let i = 0; i < NUM_CARDS; i++) {
      const card = document.createElement("div");
      card.className = "card";

      const text = document.createElement("div");
      text.className = "card-text";
      text.textContent = restaurants[i % restaurants.length];
      card.appendChild(text);

      this.stage.appendChild(card);
      this.cards.push(card);
      this.textEls.push(text);
      this.cardCenterAngles.push(SEGMENT * i);
    }

    this.applyConfig(config, host);

    host.addEventListener("pointerdown", this.onPointerDown);
    host.addEventListener("pointermove", this.onPointerMove);
    host.addEventListener("pointerup", this.onPointerUp);
    host.addEventListener("pointercancel", this.onPointerUp);

    this.draw();
    requestAnimationFrame(this.update);
  }

  /** Apply card dimensions / perspective to the DOM (called on init and resize). */
  applyConfig(config: CarouselConfig, host: HTMLElement): void {
    this.config = config;
    host.style.perspective = `${config.depthScalar}px`;

    const fontSize = config.cardWidth * config.cardFontSizeToCardWidthRatio;
    for (const card of this.cards) {
      card.style.width = `${config.cardWidth}px`;
      card.style.height = `${config.cardHeight}px`;
      card.style.marginLeft = `${-config.cardWidth / 2}px`;
      card.style.marginTop = `${-config.cardHeight / 2}px`;
      card.style.borderRadius = `${config.cardCornerRadius}px`;
    }
    for (const text of this.textEls) {
      text.style.fontSize = `${fontSize}px`;
      text.style.padding = `${config.cardPadding}px`;
    }
    this.prevDrawnAngle = -1; // force a redraw with the new geometry
    this.draw();
  }

  setRestaurants(restaurants: string[]): void {
    this.restaurants = restaurants;
    this.visibleCardToRestaurant.clear();
    this.prevDrawnAngle = -1;
    this.draw();
  }

  // ---- Render loop -------------------------------------------------------

  private update = (): void => {
    const t = now();

    switch (this.state) {
      case "idle":
        // If we somehow aren't aligned to a card, snap to the nearest one.
        if (this.frontMostCardIndex() * SEGMENT !== this.currentAngle) {
          this.snapToCard(this.frontMostCardIndex());
        }
        break;

      case "dragging":
        // Angle is updated directly in the pointermove handler; nothing to do.
        break;

      case "snapping": {
        const elapsed = t - this.snapStartTime;
        if (elapsed > this.snapDuration) {
          this.state = "idle";
          this.currentAngle = normalizeAngle(this.snapTargetAngle);
          const r = this.restaurantForCard(this.frontMostCardIndex());
          if (r) this.onChoose?.(r);
        } else {
          const progress = elapsed / this.snapDuration;
          const dist = (this.snapTargetAngle - this.snapStartAngle) * this.snapEase(progress);
          this.currentAngle = normalizeAngle(this.snapStartAngle + dist);
        }
        break;
      }

      case "decelerating": {
        const prev = Math.max(this.prevDecelTime, this.lastHistoryTime());
        const dt = t - prev;
        this.prevDecelTime = t;
        this.currentAngle = normalizeAngle(this.currentAngle + this.velocity * dt);
        this.velocity *= this.config.decelerationScalar;
        if (Math.abs(this.velocity) < MIN_VELOCITY) {
          this.velocity = 0;
          this.snapToCard(this.frontMostCardIndex());
        }
        break;
      }
    }

    if (this.currentAngle !== this.prevDrawnAngle) {
      this.draw();
    }
    requestAnimationFrame(this.update);
  };

  private draw(): void {
    const visible: number[] = [];
    const invisible: number[] = [];
    const spread = this.config.cardSpread;

    for (let i = 0; i < this.cards.length; i++) {
      const angle = normalizeAngle(this.currentAngle - i * SEGMENT);
      this.cards[i].style.transform = `rotateY(${angle}deg) translateZ(${spread}px)`;

      // Cards facing the camera (front half of the circle) are "visible".
      if ((angle >= 0 && angle <= 90) || (angle >= 270 && angle <= 360)) {
        visible.push(i);
      } else {
        invisible.push(i);
      }
    }

    this.updateCardToRestaurantMap(visible, invisible);
    for (const [cardId, restaurantId] of this.visibleCardToRestaurant) {
      this.textEls[cardId].textContent = this.restaurants[restaurantId];
    }

    this.prevDrawnAngle = this.currentAngle;
  }

  // ---- Restaurant <-> card mapping (ported verbatim) ---------------------

  private restaurantForCard(cardIndex: number): string | null {
    const idx = this.visibleCardToRestaurant.get(cardIndex);
    return idx === undefined ? null : this.restaurants[idx];
  }

  private updateCardToRestaurantMap(visible: number[], invisible: number[]): void {
    if (visible.length === 0) return;
    const map = this.visibleCardToRestaurant;
    const count = this.restaurants.length;
    let cardsToAdd = [...visible];

    if (map.size === 0) {
      map.set(visible[0], 0);
      cardsToAdd.shift();
    }

    let maxAttempts = cardsToAdd.length;
    while (cardsToAdd.length > 0) {
      const added: number[] = [];

      for (const card of cardsToAdd) {
        const left = (NUM_CARDS + (card - 1)) % NUM_CARDS;
        const right = (NUM_CARDS + (card + 1)) % NUM_CARDS;
        const leftR = map.get(left);
        const rightR = map.get(right);

        if (leftR !== undefined) {
          map.set(card, (count + (leftR - 1)) % count);
          added.push(card);
        } else if (rightR !== undefined) {
          map.set(card, (count + (rightR + 1)) % count);
          added.push(card);
        } else {
          // No mapped neighbor yet; revisit on a later pass. Bail out to a
          // reset if we can never find one (shouldn't normally happen).
          maxAttempts -= 1;
          if (maxAttempts === 0) {
            map.set(card, 0);
            added.push(card);
          }
        }
      }

      cardsToAdd = cardsToAdd.filter((c) => !added.includes(c));
    }

    for (const card of invisible) {
      map.delete(card);
    }
  }

  // ---- Snap / index helpers ----------------------------------------------

  private snapToCard(cardIndex: number): void {
    this.state = "snapping";
    this.snapStartTime = now();
    this.snapStartAngle = this.currentAngle;
    this.snapDuration = this.config.snapDuration;
    this.snapEase = easeInOutSine;

    const target = cardIndex * SEGMENT;
    let delta = target - this.snapStartAngle;
    if (Math.abs(delta) > 180 && this.snapStartAngle > 300) {
      // Wrapping from near 360 back to near 0.
      delta = 360 - this.snapStartAngle;
    }
    this.snapTargetAngle = this.currentAngle + delta;
  }

  /** Animate to a specific restaurant (used by external triggers, e.g. easter eggs). */
  spinTo(restaurant: string, duration: number): void {
    const currentR = this.restaurantForCard(this.frontMostCardIndex());
    if (!currentR) return;
    const from = this.restaurants.indexOf(currentR);
    const to = this.restaurants.indexOf(restaurant);
    if (from < 0 || to < 0) return;

    const overshoot = SEGMENT / 4;
    const angleDelta = (to - from + this.restaurants.length) * SEGMENT + overshoot;

    this.state = "snapping";
    this.snapStartTime = now();
    this.snapStartAngle = this.currentAngle;
    this.snapDuration = duration;
    this.snapEase = easeOutCirc;
    this.snapTargetAngle = this.currentAngle - angleDelta;
  }

  private frontMostCardIndex(): number {
    let idx = Math.floor((this.currentAngle + SEGMENT / 2) / SEGMENT);
    if (idx === NUM_CARDS) idx = 0;
    return idx;
  }

  // ---- Pointer input ------------------------------------------------------

  private onPointerDown = (e: PointerEvent): void => {
    e.preventDefault();
    this.state = "dragging";
    this.dragging = true;
    this.pointerId = e.pointerId;
    (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
    this.lastX = e.clientX;
    this.history = [{ t: now(), x: e.clientX }];
  };

  private onPointerMove = (e: PointerEvent): void => {
    if (!this.dragging || e.pointerId !== this.pointerId) return;
    const delta = e.clientX - this.lastX;
    this.currentAngle = normalizeAngle(this.currentAngle + delta * TOUCH_DELTA_TO_ANGLE);
    this.lastX = e.clientX;
    this.pushHistory(e.clientX);
  };

  private onPointerUp = (e: PointerEvent): void => {
    if (!this.dragging || e.pointerId !== this.pointerId) return;
    this.dragging = false;
    this.pointerId = null;
    this.pushHistory(e.clientX);

    // Average velocity over the last few samples, like the iOS touch history.
    const samples = this.history.slice(-3);
    const start = samples[0];
    const end = samples[samples.length - 1];
    const locDelta = end.x - start.x;

    if (Math.abs(locDelta) < MIN_FLING_PX) {
      this.velocity = 0;
      this.state = "idle";
      return;
    }

    const timeDelta = end.t - start.t;
    this.velocity = timeDelta > 0 ? (locDelta / timeDelta) * FLING_SCALAR : 0;
    this.prevDecelTime = now();
    this.state = "decelerating";
  };

  private pushHistory(x: number): void {
    this.history.push({ t: now(), x });
    if (this.history.length > 5) this.history.shift();
  }

  private lastHistoryTime(): number {
    return this.history.length ? this.history[this.history.length - 1].t : 0;
  }
}
