//
//  LimitedConcurrentQueue.swift
//  
//
//  Created by Arjun Dhamrait on 7/6/23.
//

import Foundation

/// Limited Concurrent Queue
/// A queue that processes a limited number of blocks at a time, sending any blocks over capacity onto the waitlist.
public class LimitedConcurrentQueue {
    private let lock: NSRecursiveLock
    private let maxWidth: Int
    private let queue: DispatchQueue
    
    
    private var currentWidth: Int = 0
    private var waitlist: [LimitedConcurrentQueueWorkItem] = []
    
    public init(width: Int) {
        maxWidth = width
        lock = NSRecursiveLock()
        queue = DispatchQueue(label: "LimitedConcurrentQueue", attributes: .concurrent)
    }
    
    // Schedules the given item to be executed on the queue
    func schedule(_ item: LimitedConcurrentQueueWorkItem) {
        lock.lock()
        defer { lock.unlock() }
        currentWidth += 1
        queue.async(execute: item.perform)
    }
    
    // Schedules the next item on the waitlist if it exists
    func scheduleNext() {
        lock.lock()
        defer { lock.unlock() }
        guard currentWidth < maxWidth else { return }
        waitlist = waitlist.filter{ !$0.isCancelled }
        guard !waitlist.isEmpty else { return }
        schedule(waitlist.removeFirst())
    }
    
    ///   Adds a block to the queue. If there is enough space in the queue, the block gets spun off as a task immediatly. If not, the
    ///   block gets put on a waitlist until there are enough resources to execute.
    /// - Parameter block: The block to add onto the queue
    /// - Returns: A cancellable LimitedConcurrentQueueWorkItem
    @discardableResult public func add(_ block: @escaping () -> Void) -> LimitedConcurrentQueueWorkItem {
        lock.lock()
        defer {lock.unlock()}
        
        let item = LimitedConcurrentQueueWorkItem { [weak self] in
            block()
            guard let self = self else { return }
            self.currentWidth -= 1
            self.scheduleNext()
        }
        
        
        // If we already have as many processing blocks as we can handle, put the item into the waitlist
        guard currentWidth < maxWidth else {
            waitlist.append(item)
            return item
        }
        
        // Otherwise, we can schedule the item immediately
        schedule(item)
        
        return item
    }
}
