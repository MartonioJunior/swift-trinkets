//
//  Transaction+Inventory.swift
//  Trinkets
//
//  Created by Martônio Júnior on 11/09/2026.
//

import Exchanges
import Inventory
import TrinketsUnits

public extension Transaction {
    /// Creates a drain that releases contents from the dispenser.
    /// - Parameter contents: Contents to be released.
    /// - Returns: Drain transaction.
    static func release(
        @ItemBuilder<Target.Item> _ contents: @escaping () -> Contents
    ) -> Self where Target: Dispenser, Contents == [Measurement<Target.Item, Tally>] {
        .init(contents()) { target, contents in
            target.release { contents }
        }
    }
    /// Creates a tap that stores contents to a depot.
    /// - Parameter contents: Contents to be stored.
    /// - Returns: Tap transaction.
    static func store(
        @ItemBuilder<Target.Item> _ contents: @escaping () -> Contents
    ) -> Self where Target: Depot, Contents == [Measurement<Target.Item, Tally>] {
        .init(contents()) { target, contents in
            target.store { contents }
        }
    }
}
