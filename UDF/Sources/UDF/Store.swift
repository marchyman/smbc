//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import OSLog

@Observable
@dynamicMemberLookup
@MainActor
public final class Store<State, Action> {
    private(set) public var state: State
    private let reduce: any Reducer<State, Action>

    public init(
        initialState state: State,
        reduce: any Reducer<State, Action>,
        name: String? = nil
    ) {
        self.state = state
        self.reduce = reduce
        if let name {
            Logger(subsystem: "org.snafu", category: "Store")
                .notice("\(name, privacy: .public) store created")
        }
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        state[keyPath: keyPath]
    }

    public func send(_ action: Action) {
        state = reduce(state, action)
    }

    public func send(_ action: Action,
                     sideEffects: () throws -> Void) rethrows {
        state = reduce(state, action)
        try sideEffects()
    }

    // version of send with an async side effect

    public func send(_ action: Action,
                     sideEffects: () async throws -> Void) async rethrows {
        state = reduce(state, action)
        try await sideEffects()
    }
}
