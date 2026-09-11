//
//  Trinketpedia.swift
//  Trinkets
//
//  Created by Martônio Júnior on 22/09/2025.
//

import IdentifiedCollections
import SwiftVariety

/// Data structure that contains a collection of heterogenous `Trinket` entries for a given context.
/// 
/// Works as an in-memory database of entries that can be used for quick lookup of `Trinket`-based instances.
@dynamicMemberLookup
public struct Trinketpedia {
    /// Unique identifier for databases in the Trinketpedia.
    public typealias ID = String
    /// Describes an internal registry for a given trinket type.
    public typealias Registry<T: Trinket> = IdentifiedArrayOf<T>
    // MARK: Variables
    /// Internal dictionary that manages all databases
    var databases: HeterogeneousDictionary<ID>
    /// Accesses a database by it's type.
    /// - Returns: A database of type `T`.
    public subscript<T: Trinket>(_: T.Type) -> Registry<T> {
        get { (try? databases.fetch(T.registryKey)) ?? .init() }
        set { databases.registerOrUpdate(newValue, for: T.registryKey) }
    }
    /// Accesses an entry in the Trinketpedia by it's ID.
    /// - Parameter id: Trinket identifier.
    /// - Returns: Retrieved instance of `T` stored at `id` in the database, `nil` otherwise.
    public subscript<T: Trinket>(_: T.Type = T.self, id id: T.ID) -> T? {
        self[T.self][id: id]
    }
    /// Accesses an entry in the Trinketpedia by it's ID.
    /// - Parameter member: Trinket identifier.
    /// - Returns: Retrieved instance of `T` stored at `id` in the database, `nil` otherwise.
    public subscript<T: Trinket>(dynamicMember member: String) -> T? where T.ID == String {
        self[T.self, id: member]
    }
    /// Accesses an entry in the Trinketpedia by it's key.
    /// - Parameter key: Trinket key.
    /// - Returns: Retrieved instance of `T` stored at `key`'s ID in the database, `nil` otherwise.
    public subscript<T: Trinket>(key: TrinketKey<T>) -> T? {
        self[T.self, id: key.id]
    }
    // MARK: Initializers
    /// Creates a new Trinketpedia.
    /// - Parameter databases: Dictionary containing all databases to be seeded in at initialization.
    public init(_ databases: HeterogeneousDictionary<ID> = [:]) {
        self.databases = databases
    }
    // MARK: Methods
    /// Obtains a trinket by it's identifier.
    /// - Parameter id: Trinket ID.
    /// - Returns: The respective trinket instance, `nil` if none were found.
    public func fetch<T: Trinket>(id: T.ID) -> T? { self[T.self, id: id] }
    /// Registers a database into the trinketpedia.
    /// 
    /// If a database already exists, it's contents are merged together.
    /// - Parameters:
    ///   - database: Database with entries to be added in
    ///
    public mutating func register<T: Trinket>(_: T.Type = T.self, _ database: Registry<T>) {
        let key = T.registryKey

        do {
            var registry = try databases.fetch(key)
            registry.append(contentsOf: database)
            databases.registerOrUpdate(registry, for: key)
        } catch let error { // swiftlint:disable:this untyped_error_in_catch
            switch error {
                case .invalidKey:
                    databases.registerOrUpdate(database, for: key)
                case .typeMismatch:
                    return
            }
        }
    }
    /// Erases all entries for a given type.
    public mutating func removeDatabase<T: Trinket>(_: T.Type) {
        databases.removeValue(forKey: T.registryKey)
    }
    /// Erases all entries in the Trinketpedia.
    public mutating func removeAll() {
        databases.removeAll()
    }
}

// MARK: Self: Sendable
extension Trinketpedia: @unchecked Sendable {}
