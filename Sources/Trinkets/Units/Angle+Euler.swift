//
//  Angle+Euler.swift
//  Trinkets
//
//  Created by Martônio Júnior on 24/04/2026.
//

import Mathe
import Numerics
import SI
import Tagged
import TrinketsUnits

@available(macOS 26.0, *)
public extension Angle {
    static func fromEuler(
        forward: Vector<3, Double>,
        up: Vector<3, Double>
    ) -> Vector<3, Tagged<Angle.Radians, Double>> {
        .init([
            .init(Double.atan2(y: forward.y, x: forward.z)),
            .init(Double.atan2(y: forward.x, x: forward.z)),
            .init(Double.atan2(y: up.x, x: up.y))
        ])
    }
}

// MARK: Measurement (EX)
public extension Tagged where Tag == Angle.Degrees, RawValue: SignedNumeric & Comparable {
    static func eulerAngle(_ value: RawValue) -> Self {
        let angle = if value > 180 {
            -(360 - value)
        } else if value < -180 {
            360 + value
        } else {
            value
        }

        return .init(angle)
    }
}
