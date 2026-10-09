//
//  TurnBased.swift
//  Trinkets
//
//  Created by Martônio Júnior on 03/07/2026.
//

import Flow

/// Describes how turns work in a turn-based game.
public protocol TurnBased: Hashable, Sendable {
    /// Type representing the progress of a turn.
    associatedtype Progress: Comparable, Hashable, Sendable
    // MARK: Methods
    /// Initial progress of a turn based on it's number.
    /// - Parameter number: Turn number.
    /// - Returns: Initial progress for a turn.
    func initialProgress(inTurn number: Int) -> Progress
    /// Checks progress to see if the turn can be ended.
    /// - Parameters:
    ///   - progress: Progress made in a turn.
    ///   - number: Turn number
    ///
    /// - Returns: `true` when the turn can be ended, `false` otherwise.
    func progress(_ progress: Progress, canEndTurn number: Int) -> Bool
}

// MARK: Default Implementation
public extension TurnBased {
    /// Checks progress to see if the turn can be ended.
    /// - Parameter turn: Turn to be evaluated.
    /// - Returns: `true` when the turn can be ended, `false` otherwise.
    func canEnd(_ turn: Turn) -> Bool {
        progress(turn.progress, canEndTurn: turn.number)
    }
    /// Initial state for a turn based on it's number.
    /// - Parameter number: Turn number.
    /// - Returns: Initial state for the turn.
    func initialState(forTurn number: Int) -> Turn {
        .init(number, progress: initialProgress(inTurn: number))
    }
    /// Attempts to go to the next turn.
    /// - Parameter turn: Current turn.
    /// - Returns: Next turn when ended successfully, current `turn` otherwise.
    func nextTurn(after turn: Turn) -> Turn {
        guard canEnd(turn) else { return turn }

        return skip(.forward, from: turn)
    }
    /// Skips a number of turns forward or backwards from the current one.
    /// - Parameters:
    ///   - tempo: How many turns should be skipped?
    ///   - turn: Starting point of the skip.
    ///
    /// - Returns: Turn after skipping.
    func skip(_ tempo: Tempo<Int>, from turn: Turn) -> Turn {
        initialState(forTurn: turn.number + 1 * tempo)
    }
}
