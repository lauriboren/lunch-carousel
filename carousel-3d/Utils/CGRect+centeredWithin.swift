import UIKit

extension CGRect {
    init(size: CGSize, centeredWithin container: CGSize) {
        let x = container.width / 2 - size.width / 2
        let y = container.height / 2 - size.height / 2
        self = CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
