//
//  Milestone.swift
//  Trinkets
//
//  Created by Martônio Júnior on 24/10/2025.
//

public protocol Milestone<Requirements, Subject>: Equatable {
    associatedtype Requirements = Never
    associatedtype Subject = Void

    func requirements(for subject: Subject) -> Requirements
}

// MARK: Default Implementation
public extension Milestone where Self: CaseIterable {
    static func `for`(
        _ subject: Subject,
        comparer: (Subject, Requirements) -> Bool
    ) -> [Self] {
        Self.allCases.milestones(for: subject, comparer: comparer)
    }
}

// MARK: Self.Requirements == Never
public extension Milestone where Requirements == Never {
    func requirements(for: Subject) -> Requirements {
        fatalError(
            """
            This rating system does not use requirements.

            Do not access it's 'requirements' directly, as they may not exist.
            """
        )
    }
}

// MARK: Self.Subject == Void
public extension Milestone where Subject == Void {
    var requirements: Requirements { requirements(for: ()) }
}

// MARK: Sequence (EX)
public extension Sequence where Element: Milestone {
    func cumulative(
        _ reducer: @escaping (Element, Element) -> Element,
    ) -> [Element] {
        var milestones = [Element]()
        var accMilestone: Element!

        for milestone in self {
            if let lastMilestone = accMilestone {
                accMilestone = reducer(lastMilestone, milestone)
            } else {
                accMilestone = milestone
            }

            milestones.append(accMilestone)
        }

        return milestones
    }

    func milestones(
        for subject: Element.Subject,
        comparer: (Element.Subject, Element.Requirements) -> Bool
    ) -> [Element] {
        filter { comparer(subject, $0.requirements(for: subject)) }
    }
}
