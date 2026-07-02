import SwiftUI

public struct AtlasTypography {
    public static func largeTitle(weight: Font.Weight = .bold) -> Font {
        .system(.largeTitle, design: .rounded).weight(weight)
    }
    
    public static func title(weight: Font.Weight = .bold) -> Font {
        .system(.title, design: .rounded).weight(weight)
    }
    
    public static func title2(weight: Font.Weight = .semibold) -> Font {
        .system(.title2, design: .rounded).weight(weight)
    }
    
    public static func title3(weight: Font.Weight = .semibold) -> Font {
        .system(.title3, design: .rounded).weight(weight)
    }
    
    public static func headline(weight: Font.Weight = .semibold) -> Font {
        .system(.headline, design: .rounded).weight(weight)
    }
    
    public static func body(weight: Font.Weight = .regular) -> Font {
        .system(.body, design: .rounded).weight(weight)
    }
    
    public static func callout(weight: Font.Weight = .regular) -> Font {
        .system(.callout, design: .rounded).weight(weight)
    }
    
    public static func subheadline(weight: Font.Weight = .regular) -> Font {
        .system(.subheadline, design: .rounded).weight(weight)
    }
    
    public static func footnote(weight: Font.Weight = .regular) -> Font {
        .system(.footnote, design: .rounded).weight(weight)
    }
    
    public static func caption(weight: Font.Weight = .regular) -> Font {
        .system(.caption, design: .rounded).weight(weight)
    }
}

public extension View {
    func atlasFont(_ font: Font) -> some View {
        self.font(font)
    }
}
