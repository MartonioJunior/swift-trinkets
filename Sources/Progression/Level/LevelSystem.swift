//
//  LevelSystem.swift
//  Trinkets
//
//  Created by Martônio Júnior on 08/07/2025.
//

import Flow

/// System which defines a level-based progression.
/// 
/// Uses levels to denote higher-order progress, which are described in relation to XP,
/// which works as the base unit for progression.
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
    /// Level of progression for a given amount of experience.
    /// - Parameter xp: Amount of experience.
    /// - Returns: Level of progression.
    public func level(for xp: XP) -> Level { appraiseXP(xp) }
    /// Amount of experience required to reach a level.
    /// - Parameter level: Level of progression.
    /// - Returns: Amount of experience.
    public func requiredXP(to level: Level) -> XP { appraiseLevel(level) }
}

// MARK: Self: Progression
extension LevelSystem: ProgressionModel where XP: AdditiveArithmetic {
    // swiftlint:disable:next missing_docs
    public func progress(for xp: XP) -> LevelProgress<Level, XP> {
        let currentLevel = level(for: xp)
        let requiredAmount = requiredXP(to: currentLevel)
        let currentExpOnLevel = xp - requiredAmount

        return .init(level: currentLevel, xp: currentExpOnLevel)
    }
}

// MARK: Self.Level: Hashable
public extension LevelSystem where Level: Hashable, XP: Comparable {
    /// Creates a level system based on a lookup table.
    /// - Parameters:
    ///   - xpTable: Table describing experience thresholds for each level
    ///   - fallbackXP: Amount of experience to use in case of no entries.
    ///   - fallbackLevel: Level to use in case of no entries.
    static func table(_ xpTable: [Level: XP], fallbackXP: XP, fallbackLevel: Level) -> Self {
        let sortedXPTable = xpTable.sorted { $0.value > $1.value }

        return .init { xp in
            sortedXPTable.first { $0.value < xp }?.key ?? fallbackLevel
        } xpWorth: { level in
            guard let level, let xp = xpTable[level] else { return fallbackXP }

            return xp
        }
    }
}

// MARK: Self.Level: Strideable
public extension LevelSystem where Level: Strideable, Level.Stride == XP {
    /// Level of progression for a given amount of experience, starting from a reference level.
    /// - Parameters:
    ///   - xp: Amount of experience.
    ///   - startLevel: Level of reference.
    ///
    /// - Returns: Level of progression after combining experience and level of reference.
    func level(for xp: XP, startingFrom startLevel: Level) -> Level {
        startLevel.advanced(by: xp)
    }
    /// Amount of experience required to go from one level of progression to another.
    /// - Parameters:
    ///   - startLevel: Start level.
    ///   - targetLevel: Target level.
    ///
    /// - Returns: Amount of experience required.
    func requiredXP(from startLevel: Level, to targetLevel: Level) -> XP {
        startLevel.distance(to: targetLevel)
    }
}

public extension LevelSystem where Level: Strideable, Level.Stride == XP, XP: AdditiveArithmetic {
    /// Defines a linear level progression model, in which experience acts as a fixed step.
    /// - Parameters:
    ///   - f: Function defining experience in level offset.
    ///   - startLevel: Level of reference.
    ///   - startXP: Initial amount of experience.
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
    /// Optimizes progression data using this level system.
    /// 
    /// In this case, optimization means creating a progress representation that is fully based on
    /// the amount of experience in the progression to calculate the level of progress under this system.
    /// 
    /// This can also be used to transfer progression data used from one system into another.
    /// - Parameter data: Data to be optimized.
    /// - Returns: Optimized progression data.
    func optimize(_ data: Progress) -> Progress {
        self.progress(for: xp(for: data))
    }
    /// Amount of experience required for the current progress to reach a target level.
    /// - Parameters:
    ///   - progress: Progress in this system.
    ///   - targetLevel: Level of reference
    ///
    /// - Returns: Amount of required experience.
    func remainingXP(_ progress: Progress, to targetLevel: Level) -> XP {
        requiredXP(to: targetLevel) - xp(for: progress)
    }

    @_disfavoredOverload
    func requiredXP(from startLevel: Level, to targetLevel: Level) -> XP {
        appraiseLevel(targetLevel) - appraiseLevel(startLevel)
    }
    /// Total amount of experience for a given progress data.
    /// - Parameter progress: Progress in this system.
    /// - Returns: Raw amount of experience.
    func xp(for progress: Progress) -> XP {
        requiredXP(to: progress.level) + progress.xp
    }
}
