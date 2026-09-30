//
//  Rate+Collectables.swift
//  Trinkets
//
//  Created by Martônio Júnior on 01/01/2026.
//

import Collectables
import Progression

// MARK: Subject == Trinketpedia
public extension Appraise where Subject == Trinketpedia {
    static func trinket<T>(_ key: TrinketKey<T>) -> Self where Progress == T? {
        .init { $0[key] }
    }
}

public extension Appraise where Subject == Trinketpedia, Progress == Bool {
    static func found<T>(_ key: TrinketKey<T>) -> Self {
        .closure(Appraise<Subject, T?>.trinket(key).isSome())
    }

    static func missing<T>(_ key: TrinketKey<T>) -> Self {
        .closure(Appraise<Subject, T?>.trinket(key).isNone())
    }
}
