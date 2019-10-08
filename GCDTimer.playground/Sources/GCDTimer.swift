import Foundation

public final class GCDTimer {
    private class UnfairLock: NSObject, NSLocking {
        private var un_fair_lock = os_unfair_lock()
        
        func lock() {
            os_unfair_lock_lock(&un_fair_lock)
        }
        
        func unlock() {
            os_unfair_lock_unlock(&un_fair_lock)
        }
    }
    
    private let lock: NSLocking = UnfairLock()
    private var timer: DispatchSourceTimer?
    
    private let timeout: Double
    private let `repeat`: Bool
    private let queue: DispatchQueue
    private let completion: () -> Void
    
    public init(timeout: Double, `repeat`: Bool, queue: DispatchQueue, completion: @escaping () -> Void) {
        self.timeout = timeout
        self.`repeat` = `repeat`
        self.queue = queue
        self.completion = completion
    }
    
    deinit {
        self.invalidate()
    }
    
    public func start(now: Bool = false) {
        let timer = DispatchSource.makeTimerSource(queue: self.queue)
        timer.setEventHandler(handler: { [weak self] in
            if let strongSelf = self {
                strongSelf.completion()
                if !strongSelf.`repeat` {
                    strongSelf.invalidate()
                }
            }
        })
        
        self.lock.lock()
        self.timer = timer
        self.lock.unlock()
        
        if self.`repeat` {
            let time: DispatchTime = .now() + (now ? 0 : self.timeout)
            timer.schedule(deadline: time, repeating: self.timeout)
        } else {
            let time: DispatchTime = .now() + (now ? 0 : self.timeout)
            timer.schedule(deadline: time)
        }
        
        timer.resume()
    }
    
    public func invalidate() {
        self.lock.lock()
        self.timer?.cancel()
        self.timer = nil
        self.lock.unlock()
    }
}
