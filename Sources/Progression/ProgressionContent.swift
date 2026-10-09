//
//  ProgressionContent.swift
//  Trinkets
//
//  Created by Martônio Júnior on 30/09/2026.
//

/// Entity that provides content in which access is obtained through progression.
public protocol ProgressionContent {
    /// State to be considered when accessing this element.
    associatedtype Subject = Void
    /// Type of contents obtained upon access.
    associatedtype Contents
    /// Attempts to access progression contents for a given subject.
    /// - Parameter subject: Subject to be evaluated.
    /// - Returns: Content accessible to this `subject`.
    func contents(for subject: Subject) -> Contents?
}

// MARK: Self.Subject == Void
public extension ProgressionContent where Subject == Void {
    /// Attempts to access progression contents for a given subject.
    var contents: Contents? { contents(for: ()) }
}

// MARK: Self.Subject == Never
public extension ProgressionModel where Subject == Never {
    // swiftlint:disable:next missing_docs
    func contents(for _: Never) -> Progress {}
}
