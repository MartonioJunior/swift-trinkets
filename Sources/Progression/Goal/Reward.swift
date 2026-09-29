//
//  Reward.swift
//  Trinkets
//
//  Created by Martônio Júnior on 31/10/2025.
//

import Functional

public typealias UnlockableReward<Content, Subject> = Reward<Subject, Lock<Content>>
/// Content that is given out to a subject as a compensation for fulfilling certain criteria.
/// - Content: Contents that compose this reward.
/// - Subject: Piece of game state evaluated to access this reward.
public struct Reward<Content, Subject> {
    // MARK: Variables
    /// List of contents that compose this reward.
    var contents: Content
    /// Requirement for accessing this content.
    var accessLogic: Logic<Subject>
    // MARK: Initializers
    /// Creates a new reward.
    /// - Parameters:
    ///   - contents: List of contents that compose this reward.
    ///   - accessLogic: Requirement for accessing this content.
    ///
    public init(_ contents: Content, when accessLogic: Logic<Subject> = .closure(.always())) {
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
    /// Reward available for a given subject.
    /// - Parameter subject: State to be evaluated.
    /// - Returns: Reward for the subject, `nil` when access is denied.
    public func reward(for subject: Subject) -> Content? {
        accessLogic(subject) ? contents : nil
    }
    /// Provides temporary access to a reward.
    /// - Parameter f: Closure with access to a reward.
    /// - Throws: `E` when the closure fails to execute.
    public func temporaryAccess<E: Error>(_ f: @escaping (Content) throws(E) -> Void) throws(E) {
        try f(contents)
    }
}

// MARK: Self: Unlockable
extension Reward: Unlockable {
    // swiftlint:disable:next missing_docs
    public mutating func lock(using logic: Logic<Subject> = .closure(.never())) {
        self.accessLogic = logic
    }
}
