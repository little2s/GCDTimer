import Foundation

public final class GCDTimer {
    
    private class UnfairLock {
        private var un_fair_lock = os_unfair_lock()
        
        func lock() {
            os_unfair_lock_lock(&un_fair_lock)
        }
        
        func unlock() {
            os_unfair_lock_unlock(&un_fair_lock)
        }
    }
    
    private let lock = UnfairLock()
    private var timer: DispatchSourceTimer?
    private var isRunning = false
    
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
        invalidate()
    }
    
    public func start(now: Bool = false) {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.setEventHandler(handler: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.completion()
            if !strongSelf.`repeat` {
                strongSelf.invalidate()
            }
        })
        
        let time: DispatchTime = .now() + (now ? 0 : timeout)
        if `repeat` {
            timer.schedule(deadline: time, repeating: timeout)
        } else {
            timer.schedule(deadline: time)
        }
        
        timer.resume()
        
        lock.lock()
        defer { lock.unlock() }
        self.timer = timer
        isRunning = true
    }
    
    public func invalidate() {
        lock.lock()
        defer { lock.unlock() }
        timer?.cancel()
        timer = nil
        isRunning = false
    }
    
    public func pause() {
        lock.lock()
        defer { lock.unlock() }
        if isRunning {
            timer?.suspend()
        }
        isRunning = false
    }
    
    public func resume() {
        lock.lock()
        defer { lock.unlock() }
        if !isRunning {
            timer?.resume()
        }
        isRunning = true
    }
    
}
