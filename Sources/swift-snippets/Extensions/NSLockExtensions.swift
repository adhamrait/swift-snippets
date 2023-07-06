//
//  NSLockExtensions.swift
//  
//
//  Created by Arjun Dhamrait on 7/6/23.
//

import Foundation

extension NSLock {
    func perform<T>(_ block: () -> T) -> T {
        self.lock()
        defer { self.unlock() }
        return block()
    }
}
