//
//  FractionUnit.swift
//  Trinkets
//
//  Created by Martônio Júnior on 09/02/25.
//

/// Short-hand alias for defining the efficiency of a conversion.
public typealias Efficiency<Input, Output> = FractionUnit<Output, Input>
/// Division between two units.
/// - A: Numerator unit.
/// - B: Denominator unit.
public struct FractionUnit<A, B> {
    /// Fraction that swaps numerator and denominator types around.
    public typealias Flipped = FractionUnit<B, A>
    // MARK: Variables
    /// Numerator unit.
    public var numerator: A
    /// Denominator unit.
    public var denominator: B
    // MARK: Initializers
    /// Creates a new unit fraction.
    /// - Parameters:
    ///   - numerator: Unit on top.
    ///   - denominator: Unit on bottom.
    ///
    public init(_ numerator: A, per denominator: B) where A: Quantifiable, B: Quantifiable {
        self.numerator = numerator
        self.denominator = denominator
    }
}

public extension FractionUnit where A: Quantifiable, B: Quantifiable {
    /// Fraction that swaps numerator and denominator around.
    var flipped: Flipped { .init(denominator, per: numerator) }
}

// MARK: Self: Convertible
extension FractionUnit: Convertible where A: Convertible, B: Convertible {
    // swiftlint:disable:next missing_docs
    public typealias Base = FractionUnit<A.Base, B.Base>
}

// MARK: Self: CustomStringConvertible
extension FractionUnit: CustomStringConvertible {
    // swiftlint:disable:next missing_docs
    public var description: String { "\(numerator)/\(denominator)" }
}

// MARK: Self: Domain
extension FractionUnit: Domain where A: Domain, B: Domain {
    // swiftlint:disable:next missing_docs
    public typealias Symbol = String
}

// MARK: Self: Dimension
extension FractionUnit: Dimension where A: Dimension, B: Dimension {
    // swiftlint:disable:next missing_docs
    public typealias BaseUnit = FractionUnit<A.BaseUnit, B.BaseUnit>
    // swiftlint:disable:next missing_docs
    public static var dimensionality: Dimensionality { A.dimensionality - B.dimensionality }
}

// MARK: Self: Equatable
extension FractionUnit: Equatable where A: Equatable, B: Equatable {}

// MARK: Self: Quantifiable
extension FractionUnit: Quantifiable where A: Quantifiable, B: Quantifiable {}

// MARK: Self: Hashable
extension FractionUnit: Hashable where A: Hashable, B: Hashable {}

// MARK: Self: Sendable
extension FractionUnit: Sendable where A: Sendable, B: Sendable {}

// MARK: Self: Sendable
extension FractionUnit: SendableMetatype {}

// MARK: Self: StaticQuantifiable
extension FractionUnit: StaticQuantifiable where A: StaticQuantifiable, B: StaticQuantifiable {}

// MARK: Self: StaticUnit
extension FractionUnit: StaticUnit where A: StaticUnit, B: StaticUnit {}

// MARK: Measurement (EX)
public extension Measurement where UnitType: Quantifiable, Value: FloatingPoint {
    /// Divides a measure by another.
    /// - Parameter denominator: Divisor measurement.
    /// - Returns: A new `Measurement` with the division of quantities associated to a `Fraction` of units.
    func per<T: Quantifiable>(_ denominator: Measurement<T, Value>) -> Measurement<FractionUnit<UnitType, T>, Value> {
        .init(value / denominator.value, .init(unit, per: denominator.unit))
    }
    /// Divides a measure by another.
    /// - Parameters:
    ///   - lhs: A measurement.
    ///   - rhs: Divisor measurement.
    /// - Returns: A new `Measurement` with the division of quantities associated to a `Fraction` of units.
    static func / <T: Quantifiable>(
        lhs: Self,
        rhs: Measurement<T, Value>
    ) -> Measurement<FractionUnit<UnitType, T>, Value> {
        lhs.per(rhs)
    }
    /// Flips around a fraction unit.
    /// - Returns: Flipped fraction.
    func flipped<A, B>() -> Measurement<FractionUnit<B, A>, Value> where UnitType == FractionUnit<A, B> {
        .init(1 / value, unit.flipped)
    }
}
