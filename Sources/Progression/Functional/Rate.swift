//
//  Rate.swift
//  Trinkets
//
//  Created by Martônio Júnior on 24/10/2025.
//

import Functional
import Global

public struct Rate<Subject, Grade> {
    // MARK: Variables
    var evaluate: (Subject) -> Grade

    // MARK: Initializers
    public init(_: Subject.Type = Subject.self, evaluating evaluate: @escaping (Subject) -> Grade) {
        self.evaluate = evaluate
    }

    public init<Input, Output>(
        _: Subject.Type = Subject.self,
        basedOn elements: some Sequence<Input>,
        grade: @escaping (Subject, Input) -> Output
    ) where Grade == [Output] {
        self.init { subject in
            elements.map { grade(subject, $0) }
        }
    }
}

// MARK: DotSyntax
public extension Rate {
    static func f(_ evaluate: @escaping (Subject) -> Grade) -> Self {
        .init(evaluating: evaluate)
    }

    static func closure<C: SyncClosure>(
        _ closure: @autoclosure () -> C
    ) -> Self where C.Input == Subject, C.Output == Grade, C.Error == Never {
        .f(closure().run)
    }

    static func tracker<T: Tracker>(_ tracker: T) -> Self where Grade == [T.Element] {
        .init { _ in tracker.milestones }
    }
}

// MARK: Self: SyncClosure
extension Rate: SyncClosure {
    public typealias Input = Subject
    public typealias Output = Grade
    public typealias Error = Never

    public func run(_ input: Input) throws(Error) -> Output {
        evaluate(input)
    }
}

// MARK: Self.Grade == Bool
public typealias Logic<Subject> = Rate<Subject, Bool>

public extension Rate where Grade == Bool {
    func check(_ predicate: @escaping (Grade) -> Bool) -> Self {
        .closure(pipe(predicate))
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
public typealias Progress<Context, Value: Numeric> = Rate<Context, Value>

public extension Rate where Grade: Numeric {
    func flip() -> Self {
        .init { 1 - evaluate($0) }
    }
}

public extension Rate where Grade: Numeric & Comparable {
    var asserted: Rate<Subject, Bool> { .init { evaluate($0) >= 1 } }
    var retracted: Rate<Subject, Bool> { .init { evaluate($0) <= 0 } }
}

// MARK: Self.Grade: Optional
public typealias Unlock<Subject, Content> = Rate<Subject, Content?>

public extension Rate {
    func lock(
        where predicate: @escaping (Subject) -> Bool
    ) -> Rate<Subject, Grade?> {
        .init { predicate($0) ? nil : evaluate($0) }
    }

    func unlock(
        where predicate: @escaping (Subject) -> Bool
    ) -> Rate<Subject, Grade?> {
        .init { predicate($0) ? evaluate($0) : nil }
    }
}

// MARK: Self.Subject: Tracker
public extension Rate where Subject: Tracker {
    static func track(
        _ milestone: Subject.Element
    ) -> Self where Grade == Subject.Weight {
        .init { $0[milestone] }
    }
}

public extension Rate where Subject: Tracker, Grade == Subject.Weight, Grade == Bool {
    static func trackAny(
        _ elements: some Sequence<Subject.Element>
    ) -> Self {
        .closure(.any(elements) { $0[$1] })
    }

    static func trackAll(
        _ elements: some Sequence<Subject.Element>
    ) -> Self {
        .closure(.all(elements) { $0[$1] })
    }

    static func || (
        lhs: Self,
        rhs: Subject.Element
    ) -> Self {
        .init { lhs.evaluate($0) || $0[rhs] }
    }

    static func && (
        lhs: Self,
        rhs: Subject.Element
    ) -> Self {
        .init { lhs.evaluate($0) && $0[rhs] }
    }
}

public extension Rate where Subject: Tracker, Subject.Weight == Bool, Grade == Int {
    static func count(
        _ elements: some Sequence<Subject.Element>
    ) -> Self {
        .closure(.count(elements) { $0[$1] })
    }
}

// MARK: Milestone (EX)
public extension Milestone where Self: CaseIterable {
    static func rate(
        by check: @escaping (Subject, Requirements) -> Bool
    ) -> Rate<Subject, [Self]> {
        Self.allCases.rate(check: check)
    }

    static func rate<T>(
        _ type: T.Type,
        by check: @escaping (T, Requirements) -> Bool
    ) -> Rate<T, [Self]> where Subject == Void {
        Self.allCases.rate(type, check: check)
    }
}

public extension Rate {
    init<M: Milestone & CaseIterable>(
        _: Subject.Type = Subject.self,
        on milestoneType: M.Type = M.self,
        by check: @escaping (Subject, M.Requirements) -> Bool
    ) where Grade == [M], M.Subject == Void {
        self = milestoneType.rate(Subject.self, by: check)
    }

    static func basedOn<M: Milestone & CaseIterable>(
        _ milestoneType: M.Type = M.self,
        by check: @escaping (Subject, M.Requirements) -> Bool
    ) -> Self where Grade == [M], Subject == M.Subject {
        milestoneType.rate(by: check)
    }

    func goal<M: Milestone, T>(
        _ milestone: M,
        transform: @escaping (Grade, M.Requirements) -> T
    ) -> Rate<Subject, T> where Subject == M.Subject {
        .init {
            transform(evaluate($0), milestone.requirements(for: $0))
        }
    }
}

public extension Sequence where Element: Milestone {
    func rate(
        check: @escaping (Element.Subject, Element.Requirements) -> Bool
    ) -> Rate<Element.Subject, [Element]> {
        Rate(basedOn: self) {
            check($0, $1.requirements(for: $0)) ? $1 : Element?.none
        }
        .compacted().asRate
    }

    func rate<Subject>(
        _ type: Subject.Type,
        check: @escaping (Subject, Element.Requirements) -> Bool
    ) -> Rate<Subject, [Element]> where Element.Subject == Void {
        Rate(type, basedOn: self) {
            check($0, $1.requirements) ? $1 : Element?.none
        }
        .compacted().asRate
    }
}

// MARK: SyncClosure (EX)
public extension SyncClosure where Error == Never {
    var asRate: Rate<Input, Output> {
        Rate<Input, Output>.f(run)
    }
}
