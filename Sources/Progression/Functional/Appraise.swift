//
//  Appraise.swift
//  Trinkets
//
//  Created by Martônio Júnior on 24/10/2025.
//

import Functional
import Global

public struct Appraise<Subject, Progress> {
    // MARK: Variables
    var evaluate: (Subject) -> Progress

    // MARK: Initializers
    public init(
        _: Subject.Type = Subject.self,
        evaluation: @escaping (Subject) -> Progress
    ) {
        self.evaluate = evaluation
    }
}

// MARK: DotSyntax
public extension Appraise {
    static func f(_ evaluate: @escaping (Subject) -> Progress) -> Self {
        .init(evaluation: evaluate)
    }

    static func closure<C: SyncClosure>(
        _ closure: @autoclosure () -> C
    ) -> Self where C.Input == Subject, C.Output == Progress, C.Error == Never {
        .f(closure().run)
    }

    static func tracker<T: Tracker>(_ tracker: T) -> Self where Progress == T.Checks {
        .init { _ in tracker.activeElements }
    }
}

// MARK: Self: SyncClosure
extension Appraise: SyncClosure {
    // swiftlint:disable:next missing_docs
    public typealias Input = Subject
    // swiftlint:disable:next missing_docs
    public typealias Output = Progress
    // swiftlint:disable:next missing_docs
    public typealias Error = Never
    // swiftlint:disable:next missing_docs
    public func run(_ input: Input) throws(Error) -> Output {
        evaluate(input)
    }
}

// MARK: Self.Grade == Bool
public typealias Logic<Subject> = Appraise<Subject, Bool>

public extension Appraise where Progress == Bool {
    func check(_ predicate: @escaping (Progress) -> Bool) -> Self {
        .closure(map(predicate))
    }

    static func contains<Feature>(
        _ includes: Feature...,
        without excludes: Feature...,
        check: @escaping (Subject, Feature) -> Bool
    ) -> Self {
        .closure(.all(includes, check: check) && .any(excludes, check: check))
    }
}

// MARK: Self.Grade: Numeric
public extension Appraise where Progress: Numeric & Comparable {
    var asserted: Appraise<Subject, Bool> { .init { evaluate($0) >= 1 } }
    var retracted: Appraise<Subject, Bool> { .init { evaluate($0) <= 0 } }
}

// MARK: Self.Grade: Optional
public typealias Unlock<Subject, Content> = Appraise<Subject, Content?>

public extension Appraise {
    func lock(
        where predicate: @escaping (Subject) -> Bool
    ) -> Appraise<Subject, Progress?> {
        .init { predicate($0) ? nil : evaluate($0) }
    }

    func unlock(
        where predicate: @escaping (Subject) -> Bool
    ) -> Appraise<Subject, Progress?> {
        .init { predicate($0) ? evaluate($0) : nil }
    }
}

// MARK: Self.Subject: Tracker
public extension Appraise where Subject: Tracker {
    static func track(
        _ milestone: Subject.Element
    ) -> Self where Progress == Subject.Weight {
        .init { $0[check: milestone] }
    }
}

public extension Appraise where Subject: Tracker, Progress == Subject.Weight, Progress == Bool {
    static func trackAny(
        _ elements: some Sequence<Subject.Element>
    ) -> Self {
        .closure(.any(elements) { $0[check: $1] })
    }

    static func trackAll(
        _ elements: some Sequence<Subject.Element>
    ) -> Self {
        .closure(.all(elements) { $0[check: $1] })
    }

    static func || (
        lhs: Self,
        rhs: Subject.Element
    ) -> Self {
        .init { lhs.evaluate($0) || $0[check: rhs] }
    }

    static func && (
        lhs: Self,
        rhs: Subject.Element
    ) -> Self {
        .init { lhs.evaluate($0) && $0[check: rhs] }
    }
}

public extension Appraise where Subject: Tracker, Subject.Weight == Bool, Progress == Int {
    static func count(
        _ elements: some Sequence<Subject.Element>
    ) -> Self {
        .closure(.count(elements) { $0[check: $1] })
    }
}

// MARK: SyncClosure (EX)
public extension SyncClosure where Error == Never {
    /// Wraps the closure into `Appraise`.
    var appraise: Appraise<Input, Output> { .f(run) }
}
