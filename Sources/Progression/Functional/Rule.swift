//
//  Rule.swift
//  Trinkets
//
//  Created by Martônio Júnior on 08/11/2025.
//

import Custom
import Functional

public typealias Gate<T: Tracker, Grade> = RuleModify<T, Grade>
public typealias RuleModify<Target, Output> = Rule<Target, Target, Output>

public struct Rule<Subject, Target, Grade> {
    // MARK: Variables
    var grade: Appraise<Subject, Grade>
    var action: (inout Target, Grade) -> Void

    // MARK: Initializers
    public init(_ grade: Appraise<Subject, Grade>, _ action: @escaping (inout Target, Grade) -> Void) {
        self.grade = grade
        self.action = action
    }

    public init(
        _ evaluation: @escaping (Subject) -> Grade,
        action: @escaping (inout Target, Grade) -> Void
    ) {
        self.init(Appraise(evaluation: evaluation), action)
    }

    // MARK: Methods
    public func apply(to target: inout Target, basedOn subject: Subject) -> Grade {
        let result = grade(subject)
        action(&target, result)
        return result
    }
}

// MARK: Self: Modifier
extension Rule: Modifier where Subject == Target {
    public func apply(to target: inout Subject) -> Grade {
        apply(to: &target, basedOn: target)
    }
}

// MARK: Self.Grade == Bool
public extension Rule where Grade == Bool {
    var inverted: Self {
        .init(grade.toggle().appraise, action)
    }

    static func completed<M: Milestone>(
        _ milestone: M,
        criteria: @escaping (Subject, M) -> Bool,
        action: @escaping (inout Target, Bool) -> Void,
    ) -> Self {
        .init {
            criteria($0, milestone)
        } action: {
            action(&$0, $1)
        }
    }

    static func toggle(
        _ logic: Logic<Subject> = .closure(.always()),
        complete: @escaping (inout Target) -> Void = { _ in },
        reset: @escaping (inout Target) -> Void = { _ in }
    ) -> Self {
        .init(logic) {
            $1 ? complete(&$0) : reset(&$0)
        }
    }
}

// MARK: Self.Subject == Self.Target
public extension Rule where Subject == Target {}

public extension Rule where Subject == Target, Subject: Tracker, Subject.Weight == Grade {
    static func gate(
        for milestone: Subject.Element,
        _ grade: @autoclosure @escaping () -> Appraise<Subject, Grade>
    ) -> Self {
        .init(grade()) {
            $0[milestone] = $1
        }
    }
}
