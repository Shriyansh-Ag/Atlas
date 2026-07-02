import SwiftUI
import Observation

@Observable
public final class Router {
    public var path = NavigationPath()
    public var presentedSheet: Route?
    public var presentedFullScreenCover: Route?
    
    public init() {}
    
    public func push(_ route: Route) {
        path.append(route)
    }
    
    public func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    public func popToRoot() {
        path.removeLast(path.count)
    }
    
    public func presentSheet(_ route: Route) {
        presentedSheet = route
    }
    
    public func dismissSheet() {
        presentedSheet = nil
    }
    
    public func presentFullScreen(_ route: Route) {
        presentedFullScreenCover = route
    }
    
    public func dismissFullScreen() {
        presentedFullScreenCover = nil
    }
}
