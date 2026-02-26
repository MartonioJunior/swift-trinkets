//
//  Lock.swift
//  
//
//  Created by Martônio Júnior on 30/10/23.
//

import Foundation
import Functional

@propertyWrapper
public struct Lock<Value> {
    // MARK: Variables
    var value: Value
    var writeLock: Logic<Void>

    // MARK: PropertyWrapper
    public var wrappedValue: Value {
        get { value }
        set { if writeLock.evaluate(()) { value = newValue } }
    }

    public var projectedValue: Self {
        get { self }
        set { self = newValue }
    }

    // MARK: Initializers
    public init(
        wrappedValue: Value,
        writeLock: Logic<Void> = .closure(.always())
    ) {
        self.writeLock = writeLock
        self.value = wrappedValue
    }
}

// MARK: Self: Unlockable
extension Lock: Unlockable {
    public mutating func lock(using logic: Logic<Void> = .closure(.never())) {
        writeLock = logic
    }
}
