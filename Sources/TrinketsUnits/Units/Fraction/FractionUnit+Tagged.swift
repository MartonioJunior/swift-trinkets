//
//  FractionUnit+Tagged.swift
//  Trinkets
//
//  Created by Martônio Júnior on 15/05/2026.
//

import Tagged

// MARK: DotSyntax
public extension FractionUnit {
    /// Creates a new fraction between units.
    /// - Returns: Fraction of a static unit by another.
    static func of<Value, Da: Domain, Db: Domain>(
        _ value: Value,
        _: KeyPath<Tagged<Da, Value>, Tagged<A, Value>>,
        per _: KeyPath<Tagged<Db, Value>, Tagged<B, Value>>
    ) -> Tagged<FractionUnit<A, B>, Value> where A: StaticQuantifiable, B: StaticQuantifiable {
        .init(value)
    }
}

public extension Tagged {
    /// Creates a new fraction between units.
    /// - Returns: Fraction of a static unit by another.
    static func `in`<A: StaticQuantifiable, B: StaticQuantifiable, Da: Domain, Db: Domain, Value>(
        _: KeyPath<Tagged<Da, RawValue>, Tagged<A, Value>>,
        per _: KeyPath<Tagged<Db, RawValue>, Tagged<B, Value>>
    ) -> Tagged<FractionUnit<A, B>, Value>.Type where Tag == FractionUnit<Da, Db> {
        Tagged<FractionUnit<A, B>, Value>.self
    }
    /// Creates a fraction by dividing the current tag by a static unit.
    /// - Returns: Reference to a `Fraction` type of the given tag by a static unit.
    static func per<D: Domain, S: StaticQuantifiable, T>(
        _: (Tagged<D, RawValue>) -> Tagged<S, T>
    ) -> Tagged<FractionUnit<Tag, S>, T>.Type {
        Tagged<FractionUnit<Tag, S>, T>.self
    }
    /// Creates a fraction of static units.
    /// - Returns: Reference to a `Fraction` type of the given static units.
    static func per<S: StaticQuantifiable>(_: S.Type) -> Tagged<FractionUnit<Tag, S>, RawValue>.Type {
        Tagged<FractionUnit<Tag, S>, RawValue>.self
    }
}

// MARK: StaticQuantifiable (EX)
public extension StaticQuantifiable {
    /// Creates a fraction of static units.
    /// - Returns: Reference to a `Fraction` type of the given static units.
    static func per<S: StaticQuantifiable>(_: S.Type) -> FractionUnit<Self, S>.Type {
        FractionUnit<Self, S>.self
    }
}

// MARK: Tagged (EX)
public extension Tagged where Tag: StaticQuantifiable, RawValue: FloatingPoint {
    /// Divides a tagged value by another.
    /// - Parameter denominator: A tagged value.
    /// - Returns: A new tagged value with the division of quantities associated to a `Fraction` tag.
    func per<S: StaticQuantifiable>(_ denominator: Tagged<S, RawValue>) -> Tagged<FractionUnit<Tag, S>, RawValue> {
        .init(rawValue / denominator.rawValue)
    }
    /// Divides a tagged value by another.
    /// - Parameters:
    ///   - lhs: A tagged value
    ///   - rhs: Another tagged value.
    /// - Returns: A new tagged value with the division of quantities associated to a `Fraction` tag.
    static func / <S: StaticQuantifiable>(
        lhs: Self,
        rhs: Tagged<S, RawValue>
    ) -> Tagged<FractionUnit<Tag, S>, RawValue> {
        lhs.per(rhs)
    }
}

public extension Tagged where Tag: StaticQuantifiable {
    /// Transforms a tagged value to another fraction by converting it's numerator.
    /// - Parameter converter: Static converter for the numerator.
    /// - Returns: A new tagged value with the converted quantity.
    func convertNumerator<A, B, C>(
        _ converter: (Tagged<A, RawValue>) -> Tagged<C, RawValue>
    ) -> Tagged<FractionUnit<C, B>, RawValue> where Tag == FractionUnit<A, B> {
        .init(converter(.init(rawValue)).rawValue)
    }
    /// Transforms a tagged value to another fraction by converting it's denominator.
    /// - Parameter converter: Static converter for the denominator.
    /// - Returns: A new tagged value with the converted quantity.
    func convertDenominator<A, B, C>(
        _ converter: (Tagged<B, RawValue>) -> Tagged<C, RawValue>
    ) -> Tagged<FractionUnit<A, C>, RawValue> where Tag == FractionUnit<A, B> {
        .init(converter(.init(rawValue)).rawValue)
    }
    /// Converts to another fraction, applying conversions from denominator, then numerator.
    /// - Parameters:
    ///   - lhs: A static converter for the denominator.
    ///   - rhs: Another static converter for the numerator.
    ///
    /// - Returns: Converted value.
    func denominator<A, B, C: StaticQuantifiable, D: StaticQuantifiable>(
        _ rhs: (Tagged<B, RawValue>) -> Tagged<D, RawValue>,
        then lhs: (Tagged<A, RawValue>) -> Tagged<C, RawValue>
    ) -> Tagged<FractionUnit<C, D>, RawValue> where Tag == FractionUnit<A, B> {
        convertDenominator(rhs).convertNumerator(lhs)
    }
    /// Converts to another fraction, applying conversions from numerator, then denominator.
    /// - Parameters:
    ///   - lhs: A static converter, for the numerator.
    ///   - rhs: Another static converter, for the denominator.
    ///
    /// - Returns: Converted value.
    func numerator<A, B, C: StaticQuantifiable, D: StaticQuantifiable>(
        _ lhs: (Tagged<A, RawValue>) -> Tagged<C, RawValue>,
        then rhs: (Tagged<B, RawValue>) -> Tagged<D, RawValue>
    ) -> Tagged<FractionUnit<C, D>, RawValue> where Tag == FractionUnit<A, B> {
        convertNumerator(lhs).convertDenominator(rhs)
    }
}

public extension Tagged where Tag: StaticQuantifiable, RawValue: FloatingPoint {
    /// Flips around a fraction unit.
    /// - Returns: Flipped fraction.
    func flipped<A, B>() -> Tagged<FractionUnit<B, A>, RawValue> where Tag == FractionUnit<A, B> {
        map { 1 / $0 }.coerced(to: FractionUnit<B, A>.self)
    }
}
