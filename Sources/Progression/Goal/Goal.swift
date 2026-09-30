//
//  Goal.swift
//  Trinkets
//
//  Created by Martônio Júnior on 07/07/2025.
//

public struct Goal<Subject, Progress> {
    // MARK: Variables
    var progress: Appraise<Subject, Progress>
    var condition: Requirement<Subject, Progress>

    // MARK: Initializers
    public init(
        progress: Appraise<Subject, Progress>,
        completed: Requirement<Subject, Progress>
    ) {
        self.progress = progress
        self.condition = completed
    }

    public init(
        _ progress: @escaping (Subject) -> Progress,
        completed: @escaping (Subject, Progress) -> Bool
    ) {
        self.progress = Appraise(evaluation: progress)
        self.condition = Requirement(completed: completed)
    }

    // MARK: Methods
    public func wasCompleted(by subject: Subject) -> Bool {
        condition(subject, progress(subject))
    }
}

// MARK: Self: Progression
extension Goal: ProgressionModel {
    // swiftlint:disable:next missing_docs
    public func progress(for subject: Subject) -> Progress {
        progress.progress(for: subject)
    }
}

// MARK: Appraise (EX)
public extension Appraise {
    func goal(
        _ completed: @escaping (Subject, Progress) -> Bool
    ) -> Goal<Subject, Progress> {
        .init(progress: self, completed: Requirement(completed: completed))
    }
}
