import Foundation
import UIKit
enum Color {

    case cosmos
    case shadow
    case softDarkness
    case pinkCake
    case softWhite
    case sea
    case sky
    case darkBlue
    case electricBlue

    case custom (hexString: Int, alpha: CGFloat)
}

extension Color {

    var value: UIColor {
        var color = UIColor.clear

        switch self {
        case .cosmos:
            color = UIColor(rgb: 0x26252b)
        case .shadow:
            color = UIColor(rgb: 0x3f3d4a)
        case .softDarkness:
            color = UIColor(rgb: 0x71717f)
        case .pinkCake:
            color = UIColor(rgb: 0xf890ab)
        case .softWhite:
            color = UIColor(rgb: 0xecf0f7)
        case .sea:
            color = UIColor(rgb: 0x517890)
        case .sky:
            color = UIColor(rgb: 0x74beec)
        case .darkBlue:
            color = UIColor(rgb: 0x376595)
        case .electricBlue:
            color = UIColor(rgb: 0x491eff)
        case let .custom(hexString, alpha):
            color = UIColor(rgb: hexString, alpha: alpha)
        }

        return color
    }
}

//http://www.color-hex.com/color-palette/62760
