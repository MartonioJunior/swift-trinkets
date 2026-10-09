//
//  TurnSystem.swift
//  Trinkets
//
//  Created by Martônio Júnior on 03/07/2026.
//

import Flow

/// Instance of a turn-based system.
/// 
/// Manages the entire lifecycle through a model, also keeping track of it's progress.
public struct TurnSystem<Model: TurnBased> {
    // MARK: Variables
    /// Logic model managing the turns.
    var core: Model
    /// Instant representing the current turn and it's progress.
    var instant: Model.Turn
    // MARK: Initializers
    /// Creates a new turn system.
    /// - Parameters:
    ///   - core: Logic model managing the turns.
    ///   - instant: Instant representing the current turn and it's progress.
    public init(core: Model, instant: Model.Turn) {
        self.core = core
        self.instant = instant
    }
    // MARK: Methods
    /// Advances the system based on the given duration.
    /// - Parameter duration: Duration for the given system.
    public mutating func advance(by tempo: Tempo<Int>) {
        instant = core.skip(tempo, from: instant)
    }
    /// Moves the system forward to the next turn.
    public mutating func nextTurn() {
        instant = core.nextTurn(after: instant)
    }
}

// MARK: Self: Progression
extension TurnSystem: ProgressionModel {
    // swiftlint:disable:next missing_docs
    public func progress(for _: Void) -> Turn<Model> { instant }
}
