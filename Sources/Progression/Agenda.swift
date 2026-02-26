//
//  Agenda.swift
//  Trinkets
//
//  Created by Martônio Júnior on 09/11/2025.
//

import Foundation

public struct Agenda<T> {
    // MARK: Variables
    var planned: [Entry]
    var executed: [Entry] = []

    public var allEntries: [Entry] { planned + executed }

    // MARK: Initializers
    public init(_ planned: [Entry], executed: [Entry]) {
        self.planned = planned.sorted()
        self.executed = executed.sorted()
    }

    public init(_ elements: [T]) {
        planned = elements.map { .init(element: $0) }
    }

    // MARK: Methods
    mutating func clear() {
        planned = []
        executed = []
    }

    mutating func register(_ element: T, priority: Int = 0, key: String = UUID().uuidString) -> String {
        let entry = Entry(id: key, priority: priority, element: element)
        planned.append(entry)
        planned.sort()
        return key
    }

    mutating func removeElement(forKey key: String) {
        planned.removeAll { $0.id == key }
        executed.removeAll { $0.id == key }
    }

    mutating func reset() {
        planned = allEntries.sorted()
        executed = []
    }

    mutating func run(_ predicate: (T) -> Bool) {
        executed += planned.filter {
            predicate($0.element)
        }
        executed.sort()

        planned = planned.filter { element in
            executed.contains { $0.id == element.id }
        }
    }
}

// MARK: Self.Entry
public extension Agenda {
    struct Entry {
        var id: String = UUID().uuidString
        var priority: Int = 0
        var element: T
    }
}

extension Agenda.Entry: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension Agenda.Entry: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.priority < rhs.priority
    }
}

// MARK: Self: Appendable
import Custom

extension Agenda: Appendable {
    public func appending(_ value: T) -> Self {
        .init(planned + CollectionOfOne(Entry(element: value)), executed: executed)
    }
}

// MARK: Self: ExpressibleByArrayLiteral
extension Agenda: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Entry...) {
        self.planned = elements
    }
}

// MARK: Self: Removable
extension Agenda: Removable where T: Equatable {
    public func removing(_ value: T) -> Agenda {
        .init(planned.filter { $0.element != value }, executed: executed.filter { $0.element != value })
    }
}
