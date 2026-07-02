import SwiftUI

public extension Color {
    struct Atlas {
        // Core Backgrounds
        public static let background = Color.black // Pure black OLED
        public static let surface = Color(white: 0.1) // slightly elevated
        
        // Brand
        public static let primary = Color(red: 0.2, green: 0.6, blue: 1.0)
        public static let secondary = Color(white: 0.4)
        public static let accent = Color(red: 0.9, green: 0.2, blue: 0.4)
        
        // Text
        public static let textPrimary = Color.white
        public static let textSecondary = Color(white: 0.7)
        public static let textTertiary = Color(white: 0.5)
        
        // Status
        public static let success = Color.green
        public static let warning = Color.orange
        public static let error = Color.red
    }
}
