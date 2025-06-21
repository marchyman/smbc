import Testing
@testable import UDF

struct TestState: Sendable {
    var value: String = "Test"
}

enum TestAction: Equatable, Sendable {
    case action
    case actionWithSideEffect
    case sideEffectAction
}

struct TestReducer: Reducer, Sendable {
    func reduce(_ state: TestState, _ action: TestAction) -> TestState {
        var newState = state

        switch action {
        case .action:
            newState.value = "action"

        case .actionWithSideEffect:
            newState.value = "pending"

        case .sideEffectAction:
            newState.value = "side effect"
        }

        return newState
    }
}

enum TestError: Error {
    case testError
}

@MainActor
struct StateTests {

    @Test func storeInit() async throws {
        let store = Store(initialState: TestState(),
                          reduce: TestReducer(),
                          name: "Test Store")
        #expect(store.state.value == "Test")
    }

    @Test func storeAction() throws {
        let store = Store(initialState: TestState(), reduce: TestReducer())
        store.send(.action)
        #expect(store.state.value == "action")
    }

    @Test func storeAsyncAction() async throws {
        let store = Store(initialState: TestState(), reduce: TestReducer())
        await store.send(.action)
        #expect(store.state.value == "action")
    }

    @Test func storeActionWithSideEffect() throws {
        let store = Store(initialState: TestState(), reduce: TestReducer())
        store.send(.actionWithSideEffect) {
            #expect(store.state.value == "pending")
            store.send(.sideEffectAction)
        }
        #expect(store.state.value == "side effect")
    }

    @Test func storeAsyncActionWithSideEffect() async throws {
        let store = Store(initialState: TestState(), reduce: TestReducer())
        await store.send(.actionWithSideEffect) {
            #expect(store.state.value == "pending")
            await store.send(.sideEffectAction)
        }
        #expect(store.state.value == "side effect")
    }

    @Test func storeSendSideEffectThrows() throws {
        let store = Store(initialState: TestState(), reduce: TestReducer())
        #expect(throws: TestError.testError) {
            try store.send(.actionWithSideEffect) {
                #expect(store.state.value == "pending")
                throw TestError.testError
            }
        }
    }

    @Test func storeAsyncSendSideEffectThrows() async throws {
        let store = Store(initialState: TestState(), reduce: TestReducer())
        await #expect(throws: TestError.testError) {
            try await store.send(.actionWithSideEffect) {
                #expect(store.state.value == "pending")
                try await Task.sleep(nanoseconds: 100)
                throw TestError.testError
            }
        }
    }
}
