//
//  LevelSystem.swift
//  Trinkets
//
//  Created by Martônio Júnior on 08/07/2025.
//

import Flow

public struct LevelSystem<Level, XP> {
    // MARK: Variables
    var grade: Rate<XP, Level>
    var requiredXP: Rate<Level?, XP>

    // MARK: Initializers
    public init(
        grade: Rate<XP, Level>,
        requiredXP: Rate<Level?, XP>
    ) {
        self.grade = grade
        self.requiredXP = requiredXP
    }

    public init(
        _ level: @escaping (XP) -> Level,
        worth: @escaping (Level?) -> XP
    ) {
        self.grade = Rate(evaluating: level)
        self.requiredXP = Rate(evaluating: worth)
    }

    // MARK: Methods
    public func level(for xp: XP) -> Level { grade(xp) }
    public func requiredXP(to level: Level) -> XP { requiredXP(level) }
}

// MARK: Self.Level: Hashable
public extension LevelSystem where Level: Hashable, XP: Comparable {
    static func table(_ xpTable: [Level: XP], startXP: XP, startLevel: Level) -> Self {
        let sortedXPTable = xpTable.sorted { $0.value > $1.value }

        return .init { xp in
            sortedXPTable.first { $0.value < xp }?.key ?? startLevel
        } worth: { level in
            guard let level, let xp = xpTable[level] else { return startXP }

            return xp
        }
    }

    static func cumulative(
        from startLevel: Level,
        to endLevel: Level,
        by step: Level.Stride,
        reduce reducer: (XP?, XP) -> XP,
        _ grade: Rate<Level, XP>,
    ) -> Self where Level: Metronome & Comparable {
        var accumulatedXP: XP?
        var table = [Level: XP]()

        let xpTable: [Level: XP] = .init(uniqueKeysWithValues: grade.sample(startLevel.stride(to: endLevel, by: step)))

        table = xpTable.reduce(into: table) {
            let requiredXP = reducer(accumulatedXP, $1.value)
            $0.updateValue(requiredXP, forKey: $1.key)
            accumulatedXP = requiredXP
        }

        return .table(table, startXP: table[startLevel]!, startLevel: startLevel)
    }
}

// MARK: Self.Level: Metronome
public extension LevelSystem where Level: Metronome, Level.Stride == XP {
    func level(for xp: XP, startingFrom startLevel: Level) -> Level {
        startLevel.advanced(by: xp)
    }
}

// MARK: Self.Level: Milestone
public extension LevelSystem where Level: Milestone & Comparable, XP == Level.Requirements, XP: Comparable {
    static func milestones(
        _ milestones: some Sequence<Level>,
        evaluating subject: Level.Subject,
        startXP: XP, startLevel: Level
    ) -> Self {
        let sortedLevels = milestones.sorted()

        return .init { xp in
            sortedLevels.first { $0.requirements(for: subject) < xp } ?? startLevel
        } worth: { level in
            level?.requirements(for: subject) ?? startXP
        }
    }
}

// MARK: Self.Level: Stamp
public extension LevelSystem where Level: Stamp, Level.Distance == XP {
    func requiredXP(from startLevel: Level, to targetLevel: Level) -> XP {
        startLevel.distance(to: targetLevel)
    }
}

public extension LevelSystem where Level: Metronome & Stamp, Level.Stride == XP, Level.Distance == XP, XP: AdditiveArithmetic {
    static func linear(_ f: @escaping (XP) -> Level.Stride, startLevel: Level, startXP: XP) -> Self {
        .init { xp in
            startLevel.advanced(by: f(xp))
        } worth: { level in
            guard let level else { return startXP }

            return startXP + startLevel.distance(to: level)
        }
    }
}

// MARK: Self.XP: AdditiveArithmetic
public extension LevelSystem where XP: AdditiveArithmetic {
    @_disfavoredOverload
    func level(for xp: XP, startingFrom startLevel: Level) -> Level {
        grade(requiredXP(startLevel) + xp)
    }

    @_disfavoredOverload
    func requiredXP(from startLevel: Level, to targetLevel: Level) -> XP {
        requiredXP(targetLevel) - requiredXP(startLevel)
    }
}
