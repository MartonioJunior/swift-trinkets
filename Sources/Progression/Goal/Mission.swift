//
//  Mission.swift
//  Trinkets
//
//  Created by Martônio Júnior on 29/10/2025.
//

public struct Mission<M: Milestone> where M.Subject: Tracker {
    // MARK: Variables
    var milestone: M
    var logic: Logic<M.Subject>

    // MARK: Initializers
    public init(
        _ milestone: M,
        logic: Logic<M.Subject>
    ) {
        self.milestone = milestone
        self.logic = logic
    }

    public init(
        _ milestone: M,
        completed: @escaping (M.Subject) -> Bool
    ) {
        self.milestone = milestone
        self.logic = Logic(evaluating: completed)
    }

    // MARK: Methods
    public func milestone(for subject: M.Subject) -> M? {
        wasCompleted(by: subject) ? milestone : nil
    }

    public func wasCompleted(by subject: M.Subject) -> Bool {
        logic(subject)
    }
}

// MARK: Self: Equatable
extension Mission: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.milestone == rhs.milestone
    }
}

// MARK: Milestone (EX)
public extension Milestone {
    func mission(
        _ logic: Logic<Subject>
    ) -> Mission<Self> where Subject: Tracker {
        .init(self, logic: logic)
    }
}

// MARK: Rate (EX)
public extension Rate where Grade == Bool {
    func mission<M: Milestone>(
        _ milestone: M
    ) -> Mission<M> where M.Subject: Tracker, Subject == M.Subject {
        .init(milestone, logic: self)
    }
}
