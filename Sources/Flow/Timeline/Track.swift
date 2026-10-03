//
//  Track.swift
//  Trinkets
//
//  Created by Martônio Júnior on 19/10/2025.
//

import MatheRange
/// Short-hand alias for a track of type-erased blocks.
public typealias AnyTrackOf<Mask: Boundary, Element> = Track<AnyBlock<Mask, Mask.Bound, Element>>
/// Group that composes together multiple blocks of the same type as one.
/// - Chunk: Block that can be registered within this track to provide a value.
/// 
/// Tracks are recommended for defining a dynamic sequence of values of a type that is modifiable.
public struct Track<Chunk: Block> {
    /// Infinitesimal interval whose passage is instantaneous.
    public typealias Instant = Chunk.Mask.Bound
    // MARK: Variables
    /// List of chunks registered in this track.
    /// 
    /// When sampling chunks, they are evaluated in order, returning the first non-nil value found.
    /// Therefore, it's important to insert elements using the correspondent methods based in your intention:
    /// - `fill(_:)` adds the chunk to the end of the order, filling empty gaps with no value set.
    /// - `overwrite(_:)` adds the chunk to the start of the order, appearing above any chunks.
    var chunks: [Chunk]
    // MARK: Initializers
    /// Creates a new track.
    /// - Parameters:
    ///   - chunks: List of blocks registered in this track.
    public init(chunks: [Chunk]) {
        self.chunks = chunks
    }
    // MARK: Methods
    /// Adds a chunk below other chunks.
    /// - Parameter chunk: Sampler to be added.
    public mutating func append(with chunk: Chunk) {
        chunks.append(chunk)
    }
    /// Adds a chunk on top of the list, executing before any other elements.
    /// - Parameter chunk: Block to be added.
    public mutating func push(with chunk: Chunk) {
        chunks.insert(chunk, at: 0)
    }
}

// MARK: Self.Mask
public extension Track {
    /// Group of masks representing this track.
    struct Mask {
        /// List of chunk masks.
        var elements: [Chunk.Mask]
        /// Creates a new track mask.
        /// - Parameter elements: Chunk masks.
        public init(_ elements: [Chunk.Mask]) {
            self.elements = elements
        }
    }
}

extension Track.Mask: Boundary {
    // swiftlint:disable:next missing_docs
    public typealias Bound = Chunk.Mask.Bound
    // swiftlint:disable:next missing_docs
    public static func ~= (lhs: Self, rhs: Chunk.Mask.Bound) -> Bool {
        for element in lhs.elements where element.contains(rhs) {
            return true
        }

        return false
    }
}

extension Track.Mask: Equatable where Chunk.Mask: Equatable {}
extension Track.Mask: Sendable where Chunk.Mask: Sendable {}

// MARK: Self: Block
extension Track: Block where Chunk.Mask.Bound == Chunk.Instant {
    // swiftlint:disable:next missing_docs
    public var mask: Mask { .init(chunks.map(\.mask)) }
    // swiftlint:disable:next missing_docs
    public func element(on instant: Chunk.Instant) -> Chunk.Element? {
        chunks.first { $0.mask.contains(instant) }?.element(on: instant)
    }
}

// MARK: Self: Equatable
extension Track: Equatable where Chunk: Equatable {}

// MARK: Self: Selectable
extension Track: Selectable where Chunk: Selectable {
    // swiftlint:disable:next missing_docs
    public func canBeSelected(by selection: Chunk.Selection) -> Bool {
        chunks.canBeSelected(by: selection)
    }
    /// Returns all chunks that are selectable with a given selection.
    /// - Parameter selection: Selection.
    /// - Returns: Chunks selectable by this selection.
    public func chunks(in selection: Selection) -> [Chunk] {
        chunks.filter { $0.canBeSelected(by: selection) }
    }
}

// MARK: Self: Sendable
extension Track: Sendable where Chunk: Sendable {}

// MARK: Self.Chunk.Mask: Gamut
public extension Track where Chunk.Mask: Gamut & Equatable, Chunk.Mask.Bound: Comparable {
    /// Attempts to append a chunk below other chunks, provided there's space for such.
    /// - Parameter chunk: Sampler to be added.
    mutating func fill(with chunk: Chunk) {
        if chunks.contains(where: { $0.mask.isSubset(of: chunk.mask, on: \.gamut) }) { return }

        chunks.append(chunk)
    }
    /// Adds a chunk on top of the list, replacing any chunks it invalidates.
    /// - Parameter chunk: Block to be added.
    mutating func overwrite(with chunk: Chunk) {
        chunks.removeAll { chunk.mask.isSubset(of: $0.mask, on: \.gamut) }

        chunks.insert(chunk, at: 0)
    }
}

// MARK: Union (EX)
public extension Union where A: Gamut, B: Gamut, A.Bound: Comparable {
    var gamut: B { fatalError("New overlap has not been implemented yet!") }
}
