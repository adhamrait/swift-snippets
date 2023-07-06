//
//  LimitedConcurrentQueueWorkItem.swift
//  
//
//  Created by Arjun Dhamrait on 7/6/23.
//

public class LimitedConcurrentQueueWorkItem {
    
    private var cancelledState = false
    private let block: () -> Void
    
    public var isCancelled: Bool {
        get {
            return self.cancelledState
        }
        set {
            guard newValue else {
                return
            }
            self.cancelledState = true
        }
    }
    
    init (_ block: @escaping () -> Void) {
        self.block = block
    }
    
    /// Performs the work
    public func perform() {
        block()
    }
}
