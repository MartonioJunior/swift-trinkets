//
//  ProgressionModel.swift
//  Trinkets
//
//  Created by Martônio Júnior on 30/09/2026.
//

/// Progression model.
public protocol ProgressionModel {
    /// State to be considered when evaluating the progression.
    associatedtype Subject = Void
    /// Type describing the progress for this model.
    associatedtype Progress
    /// Progress attained by a given subject.
    /// - Parameter subject: Subject to be evaluated.
    /// - Returns: Progress made by `subject`.
    func progress(for subject: Subject) -> Progress
}

// MARK: Self.Subject == Void
public extension ProgressionModel where Subject == Void {
    /// Progress attained by this model.
    var progress: Progress { progress(for: ()) }
}

// MARK: Self.Subject == Never
public extension ProgressionModel where Subject == Never {
    // swiftlint:disable:next missing_docs
    func progress(for _: Never) -> Progress {}
}
