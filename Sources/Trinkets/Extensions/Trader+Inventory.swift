//
//  Trader+Inventory.swift
//  Trinkets
//
//  Created by Martônio Júnior on 11/09/2026.
//

import Exchanges
import Inventory
import TrinketsUnits

public extension Trader where Self: Depot {
    mutating func buy(_ contents: Buy) -> Buy where Buy == [Measurement<Item, Tally>] {
        store { contents }
    }
}

public extension Trader where Self: Dispenser {
    mutating func sell(_ contents: Sell) -> Sell where Sell == [Measurement<Item, Tally>] {
        release { contents }
    }
}
