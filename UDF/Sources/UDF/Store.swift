//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import OSLog

@Observable
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

    public func send(_ action: Action) {
        state = reduce(state, action)
    }

    public func send(_ action: Action,
                     sideEffects: () throws -> Void) rethrows {
        state = reduce(state, action)
        try sideEffects()
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
