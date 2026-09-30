//
//  Reward.swift
//  Trinkets
//
//  Created by Martônio Júnior on 31/10/2025.
//

import Functional

public typealias UnlockableReward<Contents, Subject> = Reward<Subject, Locked<Subject, Contents>>
/// Content that is given out to a subject as a compensation for fulfilling certain criteria.
/// - Content: Contents that compose this reward.
/// - Subject: Piece of game state evaluated to access this reward.
public struct Reward<Contents, Subject> {
    // MARK: Variables
    /// List of contents that compose this reward.
    var contents: Contents
    /// Requirement for accessing this content.
    var accessLogic: Logic<Subject>
    // MARK: Initializers
    /// Creates a new reward.
    /// - Parameters:
    ///   - contents: List of contents that compose this reward.
    ///   - accessLogic: Requirement for accessing this content.
    ///
    public init(_ contents: Contents, when accessLogic: Logic<Subject> = .closure(.always())) {
        self.contents = contents
        self.accessLogic = accessLogic
    }
    // MARK: Methods
    /// Evaluates whether a subject can access this reward.
    /// - Parameter subject: State to be evaluated.
    /// - Returns: `true` is access is allowed, `false` otherwise.
    public func isObtainable(by subject: Subject) -> Bool {
        accessLogic(subject)
    }
    /// Provides temporary access to a reward.
    /// - Parameter f: Closure with access to a reward.
    /// - Throws: `E` when the closure fails to execute.
    public func temporaryAccess<E: Error>(_ f: @escaping (Contents) throws(E) -> Void) throws(E) {
        try f(contents)
    }
}

// MARK: DotSyntax
public extension Reward {
    func unlocked(_ content: Contents) -> Self { .init(content) }
}

// MARK: Self: Equatable
extension Reward: Equatable where Contents: Equatable {
    // swiftlint:disable:next missing_docs
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.contents == rhs.contents
    }
}

// MARK: Self: ProgressionContent
extension Reward: ProgressionContent {
    // swiftlint:disable:next missing_docs
    public func contents(for subject: Subject) -> Contents? {
        accessLogic(subject) ? contents : nil
    }
}

// MARK: Self: Progression
extension Reward: ProgressionModel {
    // swiftlint:disable:next missing_docs
    public func progress(for subject: Subject) -> Bool {
        accessLogic(subject)
    }
}

// MARK: Self: Unlockable
extension Reward: Unlockable {
    // swiftlint:disable:next missing_docs
    public mutating func lock(using logic: Logic<Subject> = .closure(.never())) {
        self.accessLogic = logic
    }
}
