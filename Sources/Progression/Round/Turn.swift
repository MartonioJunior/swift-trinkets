//
//  Turn.swift
//  Trinkets
//
//  Created by Martônio Júnior on 08/07/2026.
//

import Flow

public struct Turn<Model: TurnBased> {
    // MARK: Variables
    /// Current turn the system is in.
    var number: Int
    /// Progress for the current turn.
    var progress: Model.Progress
    // MARK: Initializers
    /// Creates a new turn system instant.
    /// - Parameters:
    ///   - number: Current turn the system is in.
    ///   - progress: Progress for the current turn.
    ///
    public init(_ number: Int, progress: Model.Progress) {
        self.number = number
        self.progress = progress
    }
}

// MARK: Self: Comparable
extension Turn: Comparable {
    // swiftlint:disable:next missing_docs
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.number == rhs.number {
            lhs.progress < rhs.progress
        } else {
            lhs.number < rhs.number
        }
    }
}

// MARK: Self: Strideable
extension Turn: Strideable {
    // swiftlint:disable:next missing_docs
    public func advanced(by n: Int) -> Turn<Model> {
        .init(number + n, progress: progress)
    }
    // swiftlint:disable:next missing_docs
    public func distance(to other: Turn<Model>) -> Int {
        other.number - number
    }
}

// MARK: TurnBased (EX)
public extension TurnBased {
    /// Alias for a turn.
    typealias Turn = Progression::Turn<Self>
}
