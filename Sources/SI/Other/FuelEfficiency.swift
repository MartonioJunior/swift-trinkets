//
//  FuelEfficiency.swift
//  Trinkets
//
//  Created by Martônio Júnior on 17/06/2025.
//

import Tagged
import TrinketsUnits

public typealias Fuel = Volume
public typealias FuelEfficiency = Efficiency<Fuel, Length>

// MARK: Self.KilometersPerLiter
public extension FuelEfficiency {
    // Symbol: km/L
    typealias KilometersPerLiter = FractionUnit<PrefixedUnit<Kilo, Length.Meters>, Volume.Liters>
}

public extension Tagged where Tag == FuelEfficiency.KilometersPerLiter, RawValue: Numeric & ExpressibleByFloatLiteral,
RawValue.FloatLiteralType == Double {
    var fuelEfficiency: Tagged<FuelEfficiency, RawValue> {
        numerator { $0.unprefixed().length } then: { $0.volume }
    }
}

public extension Tagged where Tag == FuelEfficiency, RawValue: FloatingPoint & ExpressibleByFloatLiteral,
RawValue.FloatLiteralType == Double {
    var kilometersPerLiter: Tagged<FuelEfficiency.KilometersPerLiter, RawValue> {
        denominator { $0.liters } then: { $0.meters.prefixed(with: .kilo) }
    }
}

// MARK: Self.MilesPerGallon
public extension FuelEfficiency {
    // Symbol: mpg
    typealias MilesPerGallon = FractionUnit<Length.Miles, Volume.Gallons>
}

public extension Tagged where Tag == FuelEfficiency.MilesPerGallon, RawValue: FloatingPoint & ExpressibleByFloatLiteral,
RawValue.FloatLiteralType == Double {
    var fuelEfficiency: Tagged<FuelEfficiency, RawValue> {
        numerator { $0.length } then: { $0.volume }
    }
}

public extension Tagged where Tag == FuelEfficiency, RawValue: FloatingPoint & ExpressibleByFloatLiteral,
RawValue.FloatLiteralType == Double {
    var milesPerGallon: Tagged<FuelEfficiency.MilesPerGallon, RawValue> {
        denominator { $0.gallons } then: { $0.miles }
    }
}

// MARK: Self.MilesPerImperialGallon
public extension FuelEfficiency {
    // Symbol: mpg
    typealias MilesPerImperialGallon = FractionUnit<Length.Miles, Volume.ImperialGallons>
}

public extension Tagged where Tag == FuelEfficiency.MilesPerImperialGallon, RawValue: FloatingPoint & ExpressibleByFloatLiteral,
RawValue.FloatLiteralType == Double {
    var fuelEfficiency: Tagged<FuelEfficiency, RawValue> {
        numerator { $0.length } then: { $0.volume }
    }
}

public extension Tagged where Tag == FuelEfficiency, RawValue: FloatingPoint & ExpressibleByFloatLiteral,
RawValue.FloatLiteralType == Double {
    var milesPerImperialGallon: Tagged<FuelEfficiency.MilesPerImperialGallon, RawValue> {
        denominator { $0.imperialGallons } then: { $0.miles }
    }
}

// MARK: Self.LitersPer100Kilometers
public extension FuelEfficiency {
    // Symbol: L/100km
    enum LitersPer100Kilometers: StaticUnit {
        public typealias Base = FuelEfficiency
    }
}

public extension Tagged where Tag == FuelEfficiency.LitersPer100Kilometers, RawValue: FloatingPoint & ExpressibleByFloatLiteral,
RawValue.FloatLiteralType == Double {
    var fuelEfficiency: Tagged<FuelEfficiency, RawValue> {
        map { $0 / 100 }.coerced(to: FractionUnit<Volume.Liters, PrefixedUnit<Kilo, Length.Meters>>.self)
        .numerator { $0.volume } then: { $0.unprefixed().length }
        .flipped()
        .coerced(to: FuelEfficiency.self)
    }
}

public extension Tagged where Tag == FuelEfficiency, RawValue: FloatingPoint & ExpressibleByFloatLiteral,
RawValue.FloatLiteralType == Double {
    var litersPer100Kilometers: Tagged<FuelEfficiency.LitersPer100Kilometers, RawValue> {
        flipped()
        .denominator { $0.meters.prefixed(with: .kilo).map { $0 * 100 } } then: { $0.liters }
        .coerced(to: FuelEfficiency.LitersPer100Kilometers.self)
    }
}
