import UIKit

class CardTextSizing {
    let font: UIFont
    let containerSize: CGSize
    let containerPadding: CGSize
    
    private var cache = [String: CGSize]()
    private let maxContentSize: CGSize
    
    init(font: UIFont, containerSize: CGSize, containerPadding: CGSize = .zero) {
        self.font = font
        self.containerSize = containerSize
        self.containerPadding = containerPadding
        self.maxContentSize = CGSize(
            width: containerSize.width - containerPadding.width * 2,
            height: containerSize.height - containerPadding.height * 2
        )
    }
    
    func measure(_ string: String) -> CGSize {
        if let cachedSize = cache[string] {
            return cachedSize
        }
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let attributes: [NSAttributedString.Key: Any] = [.font: self.font]
        let rect = string.boundingRect(with: self.maxContentSize, options: options, attributes: attributes, context: nil).size
        let scale = UIScreen.main.scale
        let size = CGSize(width: ceil(rect.width * scale) / scale, height: ceil(rect.height * scale) / scale)
        
        cache[string] = size
        return size
    }
}
