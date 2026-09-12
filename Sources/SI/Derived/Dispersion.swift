//
//  Dispersion.swift
//  Trinkets
//
//  Created by Martônio Júnior on 17/06/2025.
//

import Tagged
import TrinketsUnits

public enum Dispersion: Dimension {
    public typealias BaseUnit = PartsPerMillion

    public static let dimensionality: Dimensionality = [Dispersion.self: 1]
}

// MARK: Self.PartsPerMillion
public extension Dispersion {
    // Symbol: ppm
    enum PartsPerMillion: StaticUnit {
        public typealias Base = Dispersion
    }
}

public extension Tagged where Tag == Dispersion.PartsPerMillion, RawValue: Numeric {
    var dispersion: Tagged<Dispersion, RawValue> { .init(rawValue) }
}

public extension Tagged where Tag == Dispersion, RawValue: Numeric {
    var partsPerMillion: Tagged<Dispersion.PartsPerMillion, RawValue> { .init(rawValue) }
}
