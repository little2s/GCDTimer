import Foundation

class Container {
    var timer: GCDTimer?
    let queue = DispatchQueue(label: "com.meteor.queue")
    
    func play() {
        self.timer = GCDTimer(timeout: 1.0, repeat: true, queue: queue) {
            print(Thread.isMainThread)
        }
        self.timer?.start()
    }
}

var obj: Container? = Container()
obj?.play()
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    obj = nil
}
