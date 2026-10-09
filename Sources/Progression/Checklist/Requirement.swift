//
//  Requirement.swift
//  Trinkets
//
//  Created by Martônio Júnior on 29/09/2026.
//

import Functional
import MatheRange

public struct Requirement<Subject, Progress> {
    var completed: (Subject, Progress) -> Bool

    public init(completed: @escaping (Subject, Progress) -> Bool) {
        self.completed = completed
    }

    public init<T>(for element: T, check: @escaping (Subject, Progress, T) -> Bool) {
        self.init { check($0, $1, element) }
    }

    public func evaluate(_ subject: Subject, on progress: Progress) -> Bool {
        completed(subject, progress)
    }
}

// MARK: DotSyntax
public extension Requirement {
    var blocking: Self { .always(false) }
    var free: Self { .always(true) }

    static func always(_ value: Bool) -> Self {
        .init { _, _ in value }
    }
}

// MARK: Self: SyncClosure
extension Requirement: SyncClosure {
    // swiftlint:disable:next missing_docs
    public typealias Input = (Subject, Progress)
    // swiftlint:disable:next missing_docs
    public typealias Output = Bool
    // swiftlint:disable:next missing_docs
    public typealias Error = Never
    // swiftlint:disable:next missing_docs
    public func run(_ input: (Subject, Progress)) throws(Never) -> Bool {
        completed(input.0, input.1)
    }
}

// MARK: Boundary (EX)
public extension Requirement {
    /// Creates a requirement from a boundary.
    /// - Parameter boundary: Boundary.
    static func boundary<B: Boundary>(_ boundary: B, _: Subject.Type = Subject.self) -> Self where B.Bound == Progress {
        .init { _, progress in boundary.contains(progress) }
    }
}
