//
//  Locked.swift
//  Trinkets
//
//  Created by Martônio Júnior on 30/10/23.
//

import Foundation
import Functional

@propertyWrapper
public struct Locked<Contents, Subject> {
    // MARK: Variables
    var contents: Contents
    var writeLock: Logic<Subject>

    // MARK: PropertyWrapper
    @_disfavoredOverload
    public var wrappedValue: Contents { contents }

    public var projectedValue: Self {
        get { self }
        set { self = newValue }
    }

    // MARK: Initializers
    public init(
        wrappedValue: Contents,
        _: Subject.Type = Subject.self,
        writeLock: Logic<Subject> = .closure(.always())
    ) {
        self.contents = wrappedValue
        self.writeLock = writeLock
    }

    public mutating func mutateContents<E: Error>(
        using subject: Subject,
        _ f: (inout Contents) throws(E) -> Void
    ) throws(E) {
        guard writeLock(subject) else { return }

        try f(&contents)
    }
}

// MARK: Self: ProgressionContent
extension Locked: ProgressionContent {
    // swiftlint:disable:next missing_docs
    public func contents(for subject: Subject) -> Contents? {
        guard writeLock(subject) else { return nil }

        return contents
    }
}

// MARK: Self: Unlockable
extension Locked: Unlockable {
    // swiftlint:disable:next missing_docs
    public mutating func lock(using logic: Logic<Subject> = .closure(.never())) {
        writeLock = logic
    }
}

// MARK: Self.Subject == Void
public extension Locked where Subject == Void {
    var wrappedValue: Contents {
        get { contents }
        set { if writeLock.evaluate(()) { contents = newValue } }
    }

    init(
        wrappedValue: Contents,
        writeLock: Logic<Subject> = .closure(.always())
    ) {
        self.writeLock = writeLock
        self.contents = wrappedValue
    }

    mutating func mutateContents<E: Error>(
        _ f: (inout Contents) throws(E) -> Void
    ) throws(E) {
        guard writeLock(()) else { return }

        try f(&contents)
    }
}
