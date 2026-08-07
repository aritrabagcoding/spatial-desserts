import SwiftUI
import UIKit

extension Color {
    func toHex() -> String? {
        let uic = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if uic.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return String(format: "%02lX%02lX%02lX", lroundf(Float(r)*255), lroundf(Float(g)*255), lroundf(Float(b)*255))
        }
        return nil
    }
    
    init(hex: String) {
        let h = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        guard let rgb = UInt64(h, radix: 16) else {
            self.init(.white)
            return
        }
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(UIColor(red: r, green: g, blue: b, alpha: 1.0))
    }
}

extension UIImage {
    static func safe(_ name: String) -> UIImage {
        if let img = UIImage(named: name) { return img }
        return UIImage(systemName: "photo") ?? UIImage()
    }
}

extension Image {
    static func safe(_ name: String) -> Image {
        if UIImage(named: name) != nil { return Image(name) }
        return Image(systemName: "photo")
    }
}

