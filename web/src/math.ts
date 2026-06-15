// Pure math helpers ported from the iOS app's Utils/Math.swift.
// Easing functions take a normalized progress value (0..1) and redistribute it.

export const easeInOutSine = (x: number): number => -(Math.cos(Math.PI * x) - 1) / 2;

export const easeOutCirc = (x: number): number => Math.sqrt(1 - Math.pow(x - 1, 2));

/** Keep an angle in the range [0, 360). */
export function normalizeAngle(angle: number): number {
  return ((angle % 360) + 360) % 360;
}

/** True if `v` lies between `a` and `b` (inclusive), regardless of order. */
export function isBetweenOrEqual(v: number, a: number, b: number): boolean {
  return (v >= a && v <= b) || (v >= b && v <= a);
}
