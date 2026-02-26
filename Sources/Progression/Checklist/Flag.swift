//
//  Flag.swift
//  Trinkets
//
//  Created by Martônio Júnior on 28/10/2025.
//

import Functional

public struct Flag<Value: Milestone, Target> {
    // MARK: Variables
    var milestone: Value
    var rule: Rule<Value.Subject, Target, Bool>

    var inverted: Self {
        .init(milestone, when: rule.inverted)
    }

    // MARK: Initializers
    public init(
        _ milestone: Value,
        when rule: Rule<Value.Subject, Target, Bool>
    ) {
        self.milestone = milestone
        self.rule = rule
    }

    public init(
        _ milestone: Value,
        where predicate: @escaping (Value.Subject) -> Bool,
        complete: @escaping (inout Target) -> Void = { _ in },
        reset: @escaping (inout Target) -> Void = { _ in }
    ) {
        self.milestone = milestone
        self.rule = .toggle(.f(predicate), complete: complete, reset: reset)
    }
}
