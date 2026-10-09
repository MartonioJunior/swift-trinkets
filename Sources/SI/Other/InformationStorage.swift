//
//  InformationStorage.swift
//  Trinkets
//
//  Created by Martônio Júnior on 17/06/2025.
//

import Tagged
import TrinketsUnits

public enum InformationStorage: Dimension {
    public typealias BaseUnit = Bits
}

// MARK: Self.Bits
public extension InformationStorage {
    // Symbol: b
    enum Bits: StaticUnit {
        public typealias Base = InformationStorage
    }
}

public extension Tagged where Tag == InformationStorage.Bits, RawValue: UnsignedInteger {
    var informationStorage: Tagged<InformationStorage, RawValue> { .init(rawValue) }
}

public extension Tagged where Tag == InformationStorage, RawValue: UnsignedInteger {
    var bits: Tagged<InformationStorage.Bits, RawValue> { .init(rawValue) }
}

// MARK: Self.Bytes
public extension InformationStorage {
    // Symbol: B
    enum Bytes: StaticUnit {
        public typealias Base = InformationStorage
    }
}

public extension Tagged where Tag == InformationStorage.Bytes, RawValue: UnsignedInteger {
    var informationStorage: Tagged<InformationStorage, RawValue> { .init(rawValue * 8) }
}

public extension Tagged where Tag == InformationStorage, RawValue: UnsignedInteger {
    var bytes: Tagged<InformationStorage.Bytes, RawValue> { .init(rawValue / 8) }
}

// MARK: Self.Nibbles
public extension InformationStorage {
    // Symbol: nib
    enum Nibbles: StaticUnit {
        public typealias Base = InformationStorage
    }
}

public extension Tagged where Tag == InformationStorage.Nibbles, RawValue: UnsignedInteger {
    var informationStorage: Tagged<InformationStorage, RawValue> { .init(rawValue * 4) }
}

public extension Tagged where Tag == InformationStorage, RawValue: UnsignedInteger {
    var nibbles: Tagged<InformationStorage.Nibbles, RawValue> { .init(rawValue / 4) }
}
