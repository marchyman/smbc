//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import OSLog

@Observable
@MainActor
public final class Store<State: Sendable, Action: Sendable> {
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
            Logger(subsystem: "Store", category: "user").notice("\(name, privacy: .public) store created")
        }
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        state[keyPath: keyPath]
    }

    public func send(_ action: Action) {
        state = reduce(state, action)
    }

    public func send(_ action: Action,
                     sideEffects: () -> Void) {
        state = reduce(state, action)
        sideEffects()
    }

    // async versions of send

    public func send(_ action: Action) async {
        state = reduce(state, action)
    }

    public func send(_ action: Action,
                     sideEffects: () async throws -> Void) async rethrows {
        state = reduce(state, action)
        try await sideEffects()
    }
}
