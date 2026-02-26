//
//  Fact.swift
//  Trinkets
//
//  Created by Martônio Júnior on 08/11/2025.
//

import Custom

public struct Fact<Value, Weight: Numeric> {
    // MARK: Variables
    var value: Value
    var weight: Weight

    var inverted: Self {
        .init(value, graded: 1 - weight)
    }

    // MARK: Initializers
    public init(_ value: Value, graded: Weight) {
        self.value = value
        self.weight = graded
    }
}

// MARK: Self: Appendable
extension Fact: Appendable {
    public func appending(_ value: Weight) -> Self {
        .init(self.value, graded: weight + value)
    }
}

// MARK: Self.Weight: ExpressibleByIntegerLiteral
public extension Fact where Weight: ExpressibleByIntegerLiteral {
    static func assert(_ value: Value) -> Self {
        .init(value, graded: 1)
    }

    static func retract(_ value: Value) -> Self {
        .init(value, graded: 0)
    }

    static func negate(_ value: Value) -> Self {
        .init(value, graded: -1)
    }
}

// MARK: Tracker (EX)
public extension Tracker where Weight: Numeric {
    mutating func assert(_ fact: Fact<Element, Weight>) {
        assert(fact.value, grade: fact.weight)
    }

    mutating func retract(_ fact: Fact<Element, Weight>) {
        retract(fact.value, grade: fact.weight)
    }
}
