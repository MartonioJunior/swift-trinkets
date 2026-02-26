//
//  Goal.swift
//  Trinkets
//
//  Created by Martônio Júnior on 07/07/2025.
//

public struct Goal<M: Milestone, Progress> {
    // MARK: Variables
    var milestone: M
    var progress: Rate<M.Subject, Progress>
    var completed: (Progress, M.Requirements) -> Bool

    // MARK: Initializers
    public init(
        _ milestone: M,
        progress: Rate<M.Subject, Progress>,
        completed: @escaping (Progress, M.Requirements) -> Bool
    ) {
        self.milestone = milestone
        self.progress = progress
        self.completed = completed
    }

    public init(
        _ milestone: M,
        by progress: @escaping (M.Subject) -> Progress,
        completed: @escaping (Progress, M.Requirements) -> Bool
    ) {
        self.milestone = milestone
        self.progress = Rate(evaluating: progress)
        self.completed = completed
    }

    // MARK: Methods
    public func progress(for subject: M.Subject) -> Progress {
        progress(subject)
    }

    public func milestone(for subject: M.Subject) -> M? {
        wasCompleted(by: subject) ? milestone : nil
    }

    public func wasCompleted(by subject: M.Subject) -> Bool {
        completed(progress(subject), milestone.requirements(for: subject))
    }
}

// MARK: Self: Equatable
extension Goal: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.milestone == rhs.milestone
    }
}

// MARK: Self.M.Requirements: RangeExpression
public extension Goal where M.Requirements: RangeExpression {
    init<Value, Subject, Requirements>(
        _ milestone: Value,
        range: Requirements,
        by progress: @escaping (Subject) -> Progress
    ) where M == Tier<Value, Subject, Requirements>, Progress == Requirements.Bound {
        self.init(Tier(milestone, needs: range), by: progress) {
            $1.contains($0)
        }
    }
}

// MARK: Milestone (EX)
public extension Milestone {
    func goal<Progress>(
        _ progress: @escaping (Subject) -> Progress,
        completed: @escaping (Progress, Requirements) -> Bool
    ) -> Goal<Self, Progress> {
        .init(self, by: progress, completed: completed)
    }
}

// MARK: Rate (EX)
public extension Rate {
    func goal<M: Milestone>(
        _ milestone: M,
        completed: @escaping (Grade, M.Requirements) -> Bool
    ) -> Goal<M, Grade> where Subject == M.Subject {
        .init(milestone, progress: self, completed: completed)
    }
}
