//
//  Reward.swift
//  Trinkets
//
//  Created by Martônio Júnior on 31/10/2025.
//

import Functional

public typealias UnlockableReward<Subject, Value> = Reward<Subject, Lock<Value>>

public struct Reward<Subject, Contents> {
    // MARK: Variables
    var contents: Contents
    var accessLogic: Logic<Subject>

    // MARK: Initializers
    public init(_ contents: Contents, when accessLogic: Logic<Subject> = .closure(.always())) {
        self.contents = contents
        self.accessLogic = accessLogic
    }

    // MARK: Methods
    public func obtainable(by subject: Subject) -> Bool {
        accessLogic(subject)
    }

    public func reward(for subject: Subject) -> Contents? {
        accessLogic(subject) ? contents : nil
    }

    public func temporaryAccess(_ f: @escaping (Contents) throws -> Void) rethrows {
        try f(contents)
    }
}

// MARK: Self: Unlockable
extension Reward: Unlockable {
    public mutating func lock(using logic: Logic<Subject> = .closure(.never())) {
        self.accessLogic = logic
    }
}
