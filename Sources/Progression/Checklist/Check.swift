//
//  Check.swift
//  Trinkets
//
//  Created by Martônio Júnior on 28/10/2025.
//

import Functional

public typealias Check<T: Tracker> = Rule<T, T, Bool>

// MARK: Rule (EX)
public extension Rule where Subject == Target, Subject: Tracker, Subject.Weight == Grade, Grade == Bool {
    static func check(
        _ milestone: Subject.Element,
        validate: @autoclosure @escaping () -> Logic<Subject> = .closure(.always()),
        lock: @autoclosure @escaping () -> Logic<Subject> = .closure(.never())
    ) -> Self {
        .init {
            let completed = $0[check: milestone]
            let stayCompleted = completed && validate()($0)
            let stayLocked = !completed && lock()($0)
            return (stayCompleted || stayLocked) ? completed : !completed
        } action: {
            $0[check: milestone] = $1
        }
    }
}
