import SwiftUI

public struct AtlasAnimations {
    /// Smooth spring for general transitions, view reveals, and layout changes
    public static let springSmooth = Animation.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)
    
    /// Bouncier spring for interactive elements like button presses or playful micro-interactions
    public static let springBouncy = Animation.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)
    
    /// Stiff spring for fast, responsive state changes
    public static let springStiff = Animation.spring(response: 0.3, dampingFraction: 0.9, blendDuration: 0)
    
    /// Standard ease for opacity or simple state toggles
    public static let transition = Animation.easeInOut(duration: 0.3)
}
