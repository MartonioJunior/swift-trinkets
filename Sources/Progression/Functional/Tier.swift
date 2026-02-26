//
//  Tier.swift
//  Trinkets
//
//  Created by Martônio Júnior on 24/10/2025.
//

public typealias TierOf<M: Milestone> = Tier<M, M.Subject, M.Requirements>

public struct Tier<Value: Equatable, Subject, Requirements> {
    // MARK: Variables
    var milestone: Value
    var requirements: Rate<Subject, Requirements>

    // MARK: Initializers
    public init(_ milestone: Value, _ requirements: @escaping (Subject) -> Requirements) {
        self.milestone = milestone
        self.requirements = Rate(evaluating: requirements)
    }

    public init(_ milestone: Value, needs requirements: @autoclosure @escaping () -> Requirements) {
        self.milestone = milestone
        self.requirements = .init { _ in requirements() }
    }

    public init(_ milestone: Value) where Value: Milestone, Subject == Value.Subject, Requirements == Value.Requirements {
        self.init(milestone, milestone.requirements(for:))
    }

    // MARK: Methods
    func mapRequirements<S, R>(
        _ transform: @escaping (Rate<Subject, Requirements>) -> (S) -> R,
    ) -> Tier<Value, S, R> {
        .init(milestone, transform(requirements))
    }
}

// MARK: Self: Equatable
extension Tier: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.milestone == rhs.milestone
    }
}

// MARK: Self: Milestone
extension Tier: Milestone {
    public func requirements(for subject: Subject) -> Requirements {
        requirements(subject)
    }
}
// MARK: Self.Requirements: ExpressibleByNilLiteral
public extension Tier where Requirements: ExpressibleByNilLiteral {
    var unlocked: Self { .open(milestone) }

    static func open(_ value: Value) -> Self {
        .init(value, needs: nil)
    }
}

// MARK: Sequence (EX)
public extension Sequence {
    func stackMilestones<Requirements, Milestones, Subject>(
        _ reducer: @escaping (Milestones, Milestones) -> Milestones
    ) -> [Element] where Element == Tier<Milestones, Subject, Requirements> {
        cumulative {
            Tier(reducer($0.milestone, $1.milestone), $1.requirements)
        }
    }

    func stackRequirements<Requirements, Milestones, Subject>(
        _ reducer: @escaping (Requirements, Requirements) -> Requirements
    ) -> [Element] where Element == Tier<Milestones, Subject, Requirements> {
        cumulative { acc, next in
            Tier(next.milestone) {
                let accRequirements = acc.requirements(for: $0)
                let nextRequirements = next.requirements(for: $0)
                return reducer(accRequirements, nextRequirements)
            }
        }
    }
}
