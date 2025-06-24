//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import Foundation

// A Reducer struct must define at least a reduce function. The function
// is called to reduce a state/action to a new state.

@MainActor
public protocol Reducer<State, Action>: Sendable {
    associatedtype State
    associatedtype Action

    func reduce(_ state: State, _ action: Action) -> State
}

// Reducer structs are given an implementation of callAsFuntion allowing
// instances of the struct to be used as the required reduce function.

extension Reducer {
    public func callAsFunction(_ state: State, _ action: Action) -> State {
        return self.reduce(state, action)
    }
}
