//
//  Rate+Collectables.swift
//  Trinkets
//
//  Created by Martônio Júnior on 01/01/2026.
//

import Collectables
import Progression

// MARK: Subject == Trinketpedia
public extension Rate where Subject == Trinketpedia {
    static func trinket<T>(_ key: TrinketKey<T>) -> Self where Grade == T? {
        .init { $0[key] }
    }
}

public extension Rate where Subject == Trinketpedia, Grade == Bool {
    static func found<T>(_ key: TrinketKey<T>) -> Self {
        .closure(Rate<Subject, T?>.trinket(key).isSome())
    }

    static func missing<T>(_ key: TrinketKey<T>) -> Self {
        .closure(Rate<Subject, T?>.trinket(key).isNone())
    }
}
