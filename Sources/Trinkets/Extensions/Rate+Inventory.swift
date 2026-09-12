//
//  Rate+Inventory.swift
//  Trinkets
//
//  Created by Martônio Júnior on 01/01/2026.
//

import Inventory
import Progression
import TrinketsUnits

// MARK: Self.Subject: Catalogue
public extension Rate where Subject: Catalogue, Grade == Bool {
    static func collected(
        @ItemBuilder<Subject.Item> _ contents: @escaping () -> [Measurement<Subject.Item, Tally>]
    ) -> Self where Subject.Item: Equatable {
        .init { $0.has(contents) }
    }

    static func lacking(
        @ItemBuilder<Subject.Item> _ contents: @escaping () -> [Measurement<Subject.Item, Tally>]
    ) -> Self where Subject.Item: Equatable {
        .init { $0.lacking(contents) }
    }
}
