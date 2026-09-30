//
//  Goal.swift
//  Trinkets
//
//  Created by Martônio Júnior on 07/07/2025.
//

public struct Goal<Subject, Progress> {
    // MARK: Variables
    var progression: Appraise<Subject, Progress>
    var condition: Requirement<Subject, Progress>

    // MARK: Initializers
    public init(
        progression: Appraise<Subject, Progress>,
        condition: Requirement<Subject, Progress>
    ) {
        self.progression = progression
        self.condition = condition
    }

    public init(
        _ progress: @escaping (Subject) -> Progress,
        completed: @escaping (Subject, Progress) -> Bool
    ) {
        self.progression = Appraise(evaluation: progress)
        self.condition = Requirement(completed: completed)
    }

    // MARK: Methods
    public func wasCompleted(by subject: Subject) -> Bool {
        condition(subject, progression(subject))
    }
}

// MARK: Self: Progression
extension Goal: ProgressionModel {
    // swiftlint:disable:next missing_docs
    public func progress(for subject: Subject) -> GoalProgress<Progress> {
        let x = progression.progress(for: subject)
        return .init(x, completed: condition(subject, x))
    }
}

// MARK: Appraise (EX)
public extension Appraise {
    func goal(
        _ completed: @escaping (Subject, Progress) -> Bool
    ) -> Goal<Subject, Progress> {
        .init(progression: self, condition: Requirement(completed: completed))
    }
}
