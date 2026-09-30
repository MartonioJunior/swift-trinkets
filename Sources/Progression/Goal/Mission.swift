//
//  Mission.swift
//  Trinkets
//
//  Created by Martônio Júnior on 29/10/2025.
//

public struct Mission<Contents, Subject, Progress> {
    // MARK: Variables
    var reward: Reward<Contents, Subject>
    var goal: Goal<Subject, Progress>

    // MARK: Methods
    public func wasCompleted(by subject: Subject) -> Bool {
        goal.wasCompleted(by: subject)
    }

    public func reward(for subject: Subject) -> Contents? {
        guard wasCompleted(by: subject) else { return nil }

        return reward.contents(for: subject)
    }
}

// MARK: Self: Equatable
extension Mission: Equatable where Contents: Equatable {
    // swiftlint:disable:next missing_docs
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.reward == rhs.reward
    }
}

// MARK: Self: ProgressionContent
extension Mission: ProgressionContent {
    // swiftlint:disable:next missing_docs
    public func contents(for subject: Subject) -> Contents? {
        reward.contents(for: subject)
    }
}

// MARK: Self: Progression
extension Mission: ProgressionModel {
    // swiftlint:disable:next missing_docs
    public func progress(for subject: Subject) -> Progress {
        goal.progress(for: subject)
    }
}

// MARK: Goal (EX)
public extension Goal {
    func asMission<Contents>(
        rewarding contents: Contents,
        access: @escaping (Subject) -> Bool = { _ in true }
    ) -> Mission<Contents, Subject, Progress> {
        .init(
            reward: .init(contents, when: .init(evaluation: access)),
            goal: self
        )
    }
}
