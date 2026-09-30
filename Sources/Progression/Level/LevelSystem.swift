//
//  LevelSystem.swift
//  Trinkets
//
//  Created by Martônio Júnior on 08/07/2025.
//

import Flow

public struct LevelSystem<Level, XP> {
    // MARK: Variables
    var appraiseXP: Appraise<XP, Level>
    var appraiseLevel: Appraise<Level?, XP>

    // MARK: Initializers
    public init(
        xp: Appraise<XP, Level>,
        level: Appraise<Level?, XP>
    ) {
        self.appraiseXP = xp
        self.appraiseLevel = level
    }

    public init(
        _ level: @escaping (XP) -> Level,
        xpWorth: @escaping (Level?) -> XP
    ) {
        self.appraiseXP = Appraise(evaluation: level)
        self.appraiseLevel = Appraise(evaluation: xpWorth)
    }

    // MARK: Methods
    public func level(for xp: XP) -> Level { appraiseXP(xp) }
    public func requiredXP(to level: Level) -> XP { appraiseLevel(level) }
}

// MARK: Self: Progression
extension LevelSystem: ProgressionModel where XP: AdditiveArithmetic {
    public func progress(for xp: XP) -> LevelProgress<Level, XP> {
        let currentLevel = level(for: xp)
        let requiredAmount = requiredXP(to: currentLevel)
        let currentExpOnLevel = xp - requiredAmount

        return .init(level: currentLevel, xp: currentExpOnLevel)
    }
}

// MARK: Self.Level: Hashable
public extension LevelSystem where Level: Hashable, XP: Comparable {
    static func table(_ xpTable: [Level: XP], startXP: XP, startLevel: Level) -> Self {
        let sortedXPTable = xpTable.sorted { $0.value > $1.value }

        return .init { xp in
            sortedXPTable.first { $0.value < xp }?.key ?? startLevel
        } xpWorth: { level in
            guard let level, let xp = xpTable[level] else { return startXP }

            return xp
        }
    }
}

// MARK: Self.Level: Strideable
public extension LevelSystem where Level: Strideable, Level.Stride == XP {
    func level(for xp: XP, startingFrom startLevel: Level) -> Level {
        startLevel.advanced(by: xp)
    }

    func requiredXP(from startLevel: Level, to targetLevel: Level) -> XP {
        startLevel.distance(to: targetLevel)
    }
}

public extension LevelSystem where Level: Strideable, Level.Stride == XP, XP: AdditiveArithmetic {
    static func linear(_ f: @escaping (XP) -> Level.Stride, startLevel: Level, startXP: XP) -> Self {
        .init { xp in
            startLevel.advanced(by: f(xp))
        } xpWorth: { level in
            guard let level else { return startXP }

            return startXP + startLevel.distance(to: level)
        }
    }
}

// MARK: Self.XP: AdditiveArithmetic
public extension LevelSystem where XP: AdditiveArithmetic {
    @_disfavoredOverload
    func level(for xp: XP, startingFrom startLevel: Level) -> Level {
        appraiseXP(appraiseLevel(startLevel) + xp)
    }

    func optimize(_ data: Progress) -> Progress {
        self.progress(for: xp(for: data))
    }

    func remainingXP(_ progress: Progress, to targetLevel: Level) -> XP {
        requiredXP(to: targetLevel) - xp(for: progress)
    }

    @_disfavoredOverload
    func requiredXP(from startLevel: Level, to targetLevel: Level) -> XP {
        appraiseLevel(targetLevel) - appraiseLevel(startLevel)
    }

    func xp(for progress: Progress) -> XP {
        requiredXP(to: progress.level) + progress.xp
    }
}
