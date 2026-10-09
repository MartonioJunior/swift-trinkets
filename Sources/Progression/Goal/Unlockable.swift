//
//  Unlockable.swift
//  Trinkets
//
//  Created by Martônio Júnior on 31/10/2025.
//

import Functional

public protocol Unlockable {
    associatedtype Subject

    mutating func lock(using logic: Logic<Subject>)
    mutating func unlock()
}

// MARK: Default Implementation
public extension Unlockable {
    mutating func lock() { lock(using: .closure(.never())) }
    mutating func unlock() { lock(using: .closure(.always())) }
}

// MARK: Sequence (EX)
public extension MutableCollection where Element: Unlockable {
    mutating func lockAll(using logic: Logic<Element.Subject> = .closure(.never())) {
        for i in indices {
            self[i].lock(using: logic)
        }
    }

    mutating func unlockAll() {
        for i in indices {
            self[i].unlock()
        }
    }
}
