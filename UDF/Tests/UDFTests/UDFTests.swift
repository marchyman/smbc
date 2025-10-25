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

    func doNothing() throws {
        //
    }

    @Test func storeInit() async throws {
        let store = Store(initialState: TestState(),
                          reduce: TestReducer(),
                          name: "Test Store")
        #expect(store.value == "Test")
    }

    @Test func storeAction() throws {
        let store = Store(initialState: TestState(), reduce: TestReducer())
        store.send(.action)
        #expect(store.value == "action")
    }

    @Test func storeActionWithSideEffect() {
        let store = Store(initialState: TestState(), reduce: TestReducer())
        store.send(.actionWithSideEffect) {
            #expect(store.value == "pending")
            store.send(.sideEffectAction)
        }
        #expect(store.value == "side effect")
    }

    @Test func storeActionWithThrowingSideEffect() throws {
        let store = Store(initialState: TestState(), reduce: TestReducer())
        try store.send(.actionWithSideEffect) {
            #expect(store.value == "pending")
            try doNothing()
            store.send(.sideEffectAction)
        }
        #expect(store.value == "side effect")
    }

    @Test func storeActionWithThrowingSideEffectThrows() throws {
        let store = Store(initialState: TestState(), reduce: TestReducer())
        #expect(throws: TestError.testError) {
            try store.send(.actionWithSideEffect) {
                #expect(store.value == "pending")
                throw TestError.testError
            }
        }
    }
    @Test func storeActionWithAsyncThrowingSideEffect() async throws {
        let store = Store(initialState: TestState(), reduce: TestReducer())
        try await store.send(.actionWithSideEffect) {
            #expect(store.value == "pending")
            try await Task.sleep(nanoseconds: 1000)
            store.send(.sideEffectAction)
        }
        #expect(store.value == "side effect")
    }


    @Test func storeActionWithAsyncThrowingSideEffectThrows() async throws {
        let store = Store(initialState: TestState(), reduce: TestReducer())
        await #expect(throws: TestError.testError) {
            try await store.send(.actionWithSideEffect) {
                try await Task.sleep(nanoseconds: 100)
                #expect(store.value == "pending")
                throw TestError.testError
            }
        }
    }
}
