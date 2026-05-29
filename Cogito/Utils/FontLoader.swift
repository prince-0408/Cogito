import Foundation
import UIKit
import CoreGraphics
import CoreText
import SwiftUI

public final class FontLoader {
    public static func registerFonts() {
        let fontAssets = [
            "Satoshi-Light",
            "Satoshi-LightItalic",
            "Satoshi-Regular",
            "Satoshi-Italic",
            "Satoshi-Medium",
            "Satoshi-MediumItalic",
            "Satoshi-Bold",
            "Satoshi-BoldItalic",
            "Satoshi-Black",
            "Satoshi-BlackItalic"
        ]
        
        for fontName in fontAssets {
            guard let asset = NSDataAsset(name: fontName) else {
                print("⚠️ Failed to load font asset named: \(fontName)")
                continue
            }
            
            guard let provider = CGDataProvider(data: asset.data as CFData),
                  let font = CGFont(provider) else {
                print("⚠️ Failed to create CGFont from asset data for: \(fontName)")
                continue
            }
            
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterGraphicsFont(font, &error) {
                if let errorRef = error?.takeRetainedValue() {
                    let errorDescription = CFErrorCopyDescription(errorRef) as? String
                    // CTFontManagerRegisterGraphicsFont returns false if already registered, which is common
                    print("ℹ️ CTFontManagerRegisterGraphicsFont info/error for \(fontName): \(errorDescription ?? "Unknown error")")
                }
            } else {
                print("✅ Successfully registered custom font: \(fontName)")
            }
        }
    }
}

extension Font {
    public enum SatoshiWeight {
        case light, regular, medium, bold, black
    }
    
    public static func satoshi(size: CGFloat, weight: SatoshiWeight = .regular, italic: Bool = false) -> Font {
        let fontName: String
        switch (weight, italic) {
        case (.light, false): fontName = "Satoshi-Light"
        case (.light, true): fontName = "Satoshi-LightItalic"
        case (.regular, false): fontName = "Satoshi-Regular"
        case (.regular, true): fontName = "Satoshi-Italic"
        case (.medium, false): fontName = "Satoshi-Medium"
        case (.medium, true): fontName = "Satoshi-MediumItalic"
        case (.bold, false): fontName = "Satoshi-Bold"
        case (.bold, true): fontName = "Satoshi-BoldItalic"
        case (.black, false): fontName = "Satoshi-Black"
        case (.black, true): fontName = "Satoshi-BlackItalic"
        }
        return Font.custom(fontName, size: size)
    }
    
    public static func satoshi(_ style: Font.TextStyle, weight: SatoshiWeight = .regular, italic: Bool = false) -> Font {
        let size: CGFloat
        switch style {
        case .largeTitle: size = 34
        case .title: size = 28
        case .title2: size = 22
        case .title3: size = 20
        case .headline: size = 17
        case .subheadline: size = 15
        case .body: size = 17
        case .callout: size = 16
        case .footnote: size = 13
        case .caption: size = 12
        case .caption2: size = 11
        @unknown default: size = 17
        }
        
        let fontName: String
        switch (weight, italic) {
        case (.light, false): fontName = "Satoshi-Light"
        case (.light, true): fontName = "Satoshi-LightItalic"
        case (.regular, false): fontName = "Satoshi-Regular"
        case (.regular, true): fontName = "Satoshi-Italic"
        case (.medium, false): fontName = "Satoshi-Medium"
        case (.medium, true): fontName = "Satoshi-MediumItalic"
        case (.bold, false): fontName = "Satoshi-Bold"
        case (.bold, true): fontName = "Satoshi-BoldItalic"
        case (.black, false): fontName = "Satoshi-Black"
        case (.black, true): fontName = "Satoshi-BlackItalic"
        }
        
        return Font.custom(fontName, size: size, relativeTo: style)
    }
}
