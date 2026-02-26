//
//  Tracker.swift
//  Trinkets
//
//  Created by Martônio Júnior on 09/11/2025.
//

public protocol Tracker {
    associatedtype Element: Milestone
    associatedtype Weight

    typealias Milestones = [Element]

    var milestones: Milestones { get }

    subscript(_ milestone: Element) -> Weight { get set }
}

// MARK: Weight: AdditiveArithmetic
public extension Tracker where Weight: AdditiveArithmetic {
    /// Adds weight to a given element.
    /// - Parameters:
    ///   - value: Element to have it's weight changed.
    ///   - weight: Amount to be added.
    ///
    mutating func assert(_ value: Element, grade weight: Weight) {
        self[value] += weight
    }
    /// Reduces weight for a given element.
    /// - Parameters:
    ///   - value: Element to have it's weight changed.
    ///   - weight: Amount to be removed.
    ///
    mutating func retract(_ value: Element, grade weight: Weight) {
        self[value] -= weight
    }
}

// MARK: Weight == Bool
public extension Tracker where Weight == Bool {
    /// Marks an element as completed.
    /// - Parameter value: Element to be marked.
    mutating func complete(_ value: Element) {
        self[value] = true
    }
    /// Erases an element's completion status.
    /// - Parameter value: Element to be erased.
    mutating func reset(_ value: Element) {
        self[value] = false
    }
}

// MARK: Weight: Numeric
public extension Tracker where Weight: Numeric {
    /// Sets weight 1 to a given element.
    /// - Parameters:
    ///   - value: Element to be changed.
    mutating func assert(_ value: Element) {
        assert(value, grade: 1)
    }
    /// Sets weight 0 to a given element.
    /// - Parameters:
    ///   - value: Element to be changed.
    mutating func retract(_ value: Element) {
        assert(value, grade: 0)
    }
}
