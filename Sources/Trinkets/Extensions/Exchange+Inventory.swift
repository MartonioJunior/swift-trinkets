//
//  Exchange+Inventory.swift
//  Trinkets
//
//  Created by Martônio Júnior on 19/12/2025.
//

import Exchanges
import Inventory
import TrinketsUnits

public extension Exchange where Target: Depot & Dispenser {
    /// Creates a new exchange for an inventory.
    /// - Parameters:
    ///   - purchase: Contents to be stored.
    ///   - price: Contents to be released.
    ///
    init(
        @ItemBuilder<Target.Item> _ purchase: @escaping () -> Buy,
        @ItemBuilder<Target.Item> for price: @escaping () -> Sell
    ) where Buy == [Measurement<Target.Item, Tally>], Sell == [Measurement<Target.Item, Tally>] {
        self.init(drain: .release(price), tap: .store(purchase))
    }
}
