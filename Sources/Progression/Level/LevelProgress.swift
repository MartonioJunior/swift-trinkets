//
//  LevelProgress.swift
//  Trinkets
//
//  Created by Martônio Júnior on 01/01/2026.
//

/// Data structure defining the progress in a level-based system.
public struct LevelProgress<Level, XP> {
    // MARK: Variables
    /// Level of reference.
    public var level: Level
    /// Experience of reference.
    public var xp: XP
}
