//
//  Tracker.swift
//  Trinkets
//
//  Created by Martônio Júnior on 09/11/2025.
//

public protocol Tracker {
    /// Type of milestone being tracked.
    associatedtype Element: Milestone
    /// Milestone score.
    associatedtype Weight
    /// List of milestones.
    typealias Milestones = [Element]
    /// Milestones that are active in this type.
    var milestones: Milestones { get }
    /// Score for a given milestone.
    /// - Parameter milestone: Milestone to be checked.
    /// - Returns: `Weight` for the given milestone.
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
