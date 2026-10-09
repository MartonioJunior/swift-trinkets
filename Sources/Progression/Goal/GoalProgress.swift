//
//  GoalProgress.swift
//  Trinkets
//
//  Created by Martônio Júnior on 30/09/2026.
//

/// Data structure describing progress towards a goal.
public struct GoalProgress<Progress> {
    /// Progress towards a goal.
    var progress: Progress
    /// Was the goal reached?
    var completed: Bool
    /// Creates new progress data for a goal.
    /// - Parameters:
    ///   - progress: Progress towards a goal.
    ///   - completed: Was the goal reached?
    public init(_ progress: Progress, completed: Bool) {
        self.progress = progress
        self.completed = completed
    }
}
