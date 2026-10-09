//
//  Track+Tests.swift
//  Trinkets
//
//  Created by Martônio Júnior on 07/09/2026.
//

import CustomDump
@testable import Flow
import Testing

struct TrackTests {
    typealias Chunk = BlockTests.Mock
    @Test("Creates a new track", arguments: [
        ([Chunk(12...34)])
    ])
    func initializer(chunks: [Chunk]) {
        let sut = Track<Chunk>(chunks: chunks)
        #expect(sut.chunks == chunks)
    }

    // MARK: Methods
    @Test("Adds a chunk below others")
    func append() {
        var sut = Track(chunks: [Chunk(2...6)])
        expectDifference(sut) {
            sut.append(with: Chunk(9...12))
        } changes: {
            $0.chunks = [
                Chunk(2...6),
                Chunk(9...12)
            ]
        }
    }

    @Test("Adds a chunk on top of others")
    func push() {
        var sut = Track(chunks: [Chunk(2...6)])
        expectDifference(sut) {
            sut.push(with: Chunk(9...12))
        } changes: {
            $0.chunks = [
                Chunk(9...12),
                Chunk(2...6)
            ]
        }
    }
}

// MARK: Self.Mask
struct TrackMaskTests {
    typealias Chunk = BlockTests.Mock

    @Test("Creates a new mask", arguments: [
        ([1...9, 2...4])
    ])
    func initializer(_ elements: [ClosedRange<Int>]) {
        let result = Track<Chunk>.Mask(elements)
        #expect(result.elements == elements)
    }

    struct ConformsToBoundary {
        @Test("Checks value against all sub-mask boundaries", arguments: [
            (Track<Chunk>.Mask([1...9, 12...14]), 6, true),
            (Track<Chunk>.Mask([1...9, 12...14]), 11, false),
            (Track<Chunk>.Mask([1...9, 2...4]), 6, true),
            (Track<Chunk>.Mask([]), 6, false)
        ])
        func contains(lhs: Track<Chunk>.Mask, rhs: Int, expected: Bool) {
            let result = lhs ~= rhs
            #expect(result == expected)
        }
    }
}

extension TrackTests {
    // MARK: Self: Block
    struct ConformsToBlock {
        @Test("Mask is the combined mask chunks", arguments: [
            (Track(chunks: [Chunk(2...6)]), Track<Chunk>.Mask([2...6]))
        ])
        func mask(_ sut: Track<Chunk>, expected: Track<Chunk>.Mask) {
            #expect(sut.mask == expected)
        }

        @Test("Checks each chunk mask until finding the element", arguments: [
            (Track(chunks: [Chunk(2...6)]), 3, 3),
            (Track(chunks: [Chunk(2...6), Chunk(8...9)]), 9, 9),
            (Track(chunks: [Chunk(2...6)]), 8, Optional<Int>.none),
            (Track<Chunk>(chunks: []), 3, Optional<Int>.none)
        ])
        func element(_ sut: Track<Chunk>, on instant: Int, expected: Int?) {
            let result = sut.element(on: instant)
            #expect(result == expected)
        }
    }

    // MARK: Self: Selectable
    struct ConformsToSelectable {
        typealias SelectableMask = AnyBlockTests.ConformsToSelectable.SelectableMask
        typealias Chunk = AnyBlock<SelectableMask, Int, Int>

        @Test("Selection is based on the chunks themselves", arguments: [
            (Track(chunks: [Chunk(mask: SelectableMask(2...8), f: \.self)]), 7...9, true),
            (Track(chunks: [Chunk(mask: SelectableMask(2...8), f: \.self)]), 12...15, false),
            (Track(chunks: [
                Chunk(mask: SelectableMask(2...8), f: \.self),
                Chunk(mask: SelectableMask(10...16), f: \.self)
            ]), 12...15, true)
        ])
        func canBeSelected(
            _ sut: Track<Chunk>,
            by selection: ClosedRange<Int>,
            expected: Bool
        ) {
            let result = sut.canBeSelected(by: selection)
            #expect(result == expected)
        }

        @Test("Obtains which chunks in track are part of the selection", arguments: [
            (
                Track(chunks: [
                    Chunk(mask: SelectableMask(2...8), f: \.self),
                    Chunk(mask: SelectableMask(10...16), f: \.self)
                ]),
                7...9,
                [Chunk(mask: SelectableMask(2...8), f: \.self)]
            ),
            (
                Track(chunks: [
                    Chunk(mask: SelectableMask(2...8), f: \.self),
                    Chunk(mask: SelectableMask(10...16), f: \.self)
                ]),
                7...13,
                [
                    Chunk(mask: SelectableMask(2...8), f: \.self),
                    Chunk(mask: SelectableMask(10...16), f: \.self)
                ]
            ),
            (
                Track(chunks: [
                    Chunk(mask: SelectableMask(2...8), f: \.self),
                    Chunk(mask: SelectableMask(10...16), f: \.self)
                ]),
                9...14,
                [Chunk(mask: SelectableMask(10...16), f: \.self)]
            ),
            (
                Track(chunks: [
                    Chunk(mask: SelectableMask(2...8), f: \.self),
                    Chunk(mask: SelectableMask(10...16), f: \.self)
                ]),
                22...26,
                [Chunk]()
            )
        ])
        func chunks(
            _ sut: Track<Chunk>,
            in selection: ClosedRange<Int>,
            expected: [Chunk]
        ) {
            let result = sut.chunks(in: selection)
            #expect(result.map(\.mask) == expected.map(\.mask))
        }
    }

    // MARK: Self.Chunk.Mask: Gamut
    struct ChunkMaskConformsToGamut {
        @Test("Append to fill gaps left by chunks", .disabled("Test is currently dependent on unimplemented property in `Union`"))
        func fill() {
            var envelopGap = Track(chunks: [Chunk(2...6), Chunk(10...14)])
            expectDifference(envelopGap) {
                envelopGap.fill(with: Chunk(1...8))
            } changes: {
                $0.chunks = [
                    Chunk(2...6),
                    Chunk(10...14),
                    Chunk(1...8)
                ]
            }

            var partialGap = Track(chunks: [Chunk(2...6), Chunk(10...14)])
            expectDifference(partialGap) {
                partialGap.fill(with: Chunk(1...16))
            } changes: {
                $0.chunks = [
                    Chunk(2...6),
                    Chunk(10...14),
                    Chunk(1...16)
                ]
            }

            let noGap = Track(chunks: [Chunk(2...6), Chunk(10...14)])
            expectNoChanges(noGap) {
                $0.fill(with: Chunk(11...13))
            }
        }

        @Test("Push removing redundant chunks that become unreachable", .disabled("Test is currently dependent on unimplemented property in `Union`"))
        func overwrite() {
            var rawRemoval = Track(chunks: [Chunk(2...6), Chunk(10...14)])
            expectDifference(rawRemoval) {
                rawRemoval.overwrite(with: Chunk(1...8))
            } changes: {
                $0.chunks = [
                    Chunk(1...8),
                    Chunk(10...14)
                ]
            }

            var removeBoth = Track(chunks: [Chunk(2...6), Chunk(10...14)])
            expectDifference(removeBoth) {
                removeBoth.overwrite(with: Chunk(1...16))
            } changes: {
                $0.chunks = [
                    Chunk(1...16)
                ]
            }

            var noRemoval = Track(chunks: [Chunk(2...6), Chunk(10...14)])
            expectDifference(noRemoval) {
                noRemoval.overwrite(with: Chunk(7...13))
            } changes: {
                $0.chunks = [
                    Chunk(7...13),
                    Chunk(2...6),
                    Chunk(10...14)
                ]
            }
        }
    }
}
