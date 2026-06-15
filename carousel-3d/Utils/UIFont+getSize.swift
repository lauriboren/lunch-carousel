import UIKit

extension UIFont {
    func getSize(for text: String) -> CGSize {
        (text as NSString).size(withAttributes: [NSAttributedString.Key.font : self as Any])
    }
}
