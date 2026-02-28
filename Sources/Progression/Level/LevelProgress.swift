//
//  LevelStats.swift
//  Trinkets
//
//  Created by Martônio Júnior on 01/01/2026.
//

public struct LevelProgress<Level, XP> {
    // MARK: Variables
    var level: Level
    var xp: XP
}

// MARK: LevelSystem (EX)
public extension LevelSystem {
    typealias Stats = LevelProgress<Level, XP>
}

public extension LevelSystem where XP: AdditiveArithmetic {
    func optimize(_ progress: Stats) -> Stats {
        stats(for: xp(for: progress))
    }

    func stats(for xp: XP) -> Stats {
        let currentLevel = level(for: xp)
        let requiredAmount = requiredXP(to: currentLevel)
        let currentExpOnLevel = xp - requiredAmount

        return .init(level: currentLevel, xp: currentExpOnLevel)
    }

    func remainingXP(_ progress: Stats, to targetLevel: Level) -> XP {
        requiredXP(to: targetLevel) - xp(for: progress)
    }

    func xp(for progress: Stats) -> XP {
        requiredXP(to: progress.level) + progress.xp
    }
}
