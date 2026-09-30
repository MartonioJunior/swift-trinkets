//
//  RuleSystem.swift
//  Trinkets
//
//  Created by Martônio Júnior on 08/11/2025.
//

public struct RuleSystem<Context, Element: Equatable, Weight: Numeric> {
    /// Rule used by this rule system.
    public typealias Procedure = Rule<Context, Self, Bool>
    // MARK: Variables
    var agenda: Agenda<Procedure>
    var facts: [Fact<Element, Weight>]

    var allRules: [Procedure] { agenda.allEntries.map(\.element) }

    // MARK: Methods
    public func appending(_ value: Procedure) -> RuleSystem<Context, Element, Weight> {
        .init(agenda: agenda.appending(value), facts: facts)
    }

    public mutating func clear() {
        agenda.clear()
        facts = []
    }

    public mutating func evaluate(using context: Context) {
        var current = agenda
        current.run { $0.apply(to: &self, basedOn: context) }
        self.agenda = current
    }

    public mutating func register(_ rule: Procedure, priority: Int = 0) {
        _ = agenda.register(rule, priority: priority)
    }

    public func removing(_ value: String) -> RuleSystem<Context, Element, Weight> {
        var agenda = agenda
        agenda.removeElement(forKey: value)
        return .init(agenda: agenda, facts: facts)
    }

    public mutating func reset() {
        agenda.reset()
        facts = []
    }
}

// MARK: Self: Tracker
extension RuleSystem: Tracker where Weight: Numeric & Comparable {
    /// List of milestones achieved/facts asserted in the rule system.
    public var milestones: [Element] {
        facts.filter { $0.weight >= 1 }.map(\.value)
    }
    /// Returns the weight for a given fact.
    /// - Parameter milestone: Milestone or fact to be evaluated.
    /// - Returns: `Weight` for the given fact, `.zero` if the fact is not part of the rule system.
    public subscript(_ milestone: Element) -> Weight {
        get {
            facts.first { $0.value == milestone }?.weight ?? .zero
        } set {
            guard let index = facts.firstIndex(where: { $0.value == milestone }) else { return }

            guard newValue > 0 else {
                facts.removeAll { $0.value == milestone }
                return
            }

            facts[index] = Fact(milestone, graded: max(newValue, 1))
        }
    }
}
