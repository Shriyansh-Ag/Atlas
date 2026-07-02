import Foundation
import Combine

@MainActor
public class RestTimerManager: ObservableObject {
    public static let shared = RestTimerManager()
    
    @Published public var isRunning = false
    @Published public var remainingSeconds = 0
    @Published public var totalDuration = 0
    
    private var timer: Timer?
    
    private init() {}
    
    public func start(duration: Int) {
        remainingSeconds = duration
        totalDuration = duration
        isRunning = true
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }
    
    public func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        remainingSeconds = 0
    }
    
    public func addTime(_ seconds: Int) {
        remainingSeconds += seconds
        totalDuration += seconds
    }
    
    private func tick() {
        if remainingSeconds > 0 {
            remainingSeconds -= 1
        } else {
            stop()
            // TODO: Trigger haptics/sound
        }
    }
}
