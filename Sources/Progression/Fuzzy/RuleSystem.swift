//
//  RuleSystem.swift
//  Trinkets
//
//  Created by Martônio Júnior on 08/11/2025.
//

public struct RuleSystem<Context, Value: Milestone, Weight: Numeric> {
    typealias Procedure = Rule<Context, Self, Bool>

    // MARK: Variables
    var agenda: Agenda<Procedure>
    var facts: [Fact<Value, Weight>]

    var allRules: [Procedure] { agenda.allEntries.map(\.element) }

    // MARK: Methods
    mutating func clear() {
        agenda.clear()
        facts = []
    }

    mutating func evaluate(using context: Context) {
        var current = agenda
        current.run { $0.apply(to: &self, basedOn: context) }
        self.agenda = current
    }

    mutating func register(_ rule: Procedure, priority: Int = 0) {
        _ = agenda.register(rule, priority: priority)
    }

    mutating func reset() {
        agenda.reset()
        facts = []
    }
}

// MARK: Self.Grade: Equatable
extension RuleSystem: Tracker where Weight: Comparable {
    public var milestones: Milestones {
        facts.filter { $0.weight >= 1 }.map(\.value)
    }

    public subscript(_ milestone: Value) -> Weight {
        get {
            facts.first { $0.value == milestone }?.weight ?? 0
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
