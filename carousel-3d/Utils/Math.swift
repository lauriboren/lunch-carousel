import Foundation

func easeLinear(x: CGFloat) -> CGFloat {
    return x
}

func easeOutSine(x: CGFloat) -> CGFloat {
    return sin((x * CGFloat.pi) / 2);
}

func easeOutCirc(x: CGFloat) -> CGFloat {
    return sqrt(1 - pow(x - 1, 2));
}

func easeInOutSine(x: CGFloat) -> CGFloat {
    return -(cos(CGFloat.pi * x) - 1) / 2;
}

func easeInOutCubic(x: CGFloat) -> CGFloat {
    return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2;
}

func easeInOutQuint(x: CGFloat) -> CGFloat {
    return x < 0.5 ? 16 * x * x * x * x * x : 1 - pow(-2 * x + 2, 5) / 2;
}

extension CGFloat {
    func isBetweenOrEqualTo(_ a: CGFloat, _ b: CGFloat) -> Bool {
        (self >= a && self <= b) || (self >= b && self <= a)
    }
}

func degreeToRadians(deg: CGFloat) -> CGFloat {
    return (deg * CGFloat.pi) / 180
}

func normalizeAngle(_ angle: CGFloat) -> CGFloat {
    // We want to keep angle always in range 0..<360. Unfortunately we can only do module on integers, not CGFloats,
    // we need to convert in between. But we also don't want to lose all of the precision, so for integer stuff we'll
    // multiply by 100 (to keep two decimal places) and then when done, we'll divide by 100 again.
    CGFloat((36000 + Int(angle * 100) % 36000) % 36000) / 100
}
