//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import SwiftUI
import UDF
import ASKeys
import ViewModifiers

public struct GalleryView: View {
    @Environment(Store<GalleryState, GalleryAction>.self) var store
    @State private var path: NavigationPath = .init()

    public init() {}

    public var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVStack {
                    ForEach(store.galleryModel.names, id: \.self) { name in
                        let downloadName = store.galleryServer + name
                        if name.endsInJpg() {
                            NavigationLink(destination: ImageZoomView(imageName: downloadName)) {
                                ImageView(imageName: downloadName)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            NavigationLink(destination: MarkdownZoomView(name: downloadName)) {
                                MarkdownView(name: downloadName)
                                    .frame(maxWidth: 700)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical)
                    .frame(height: 300)
                }
            }
            .smbcBackground()
            .refreshable { Task { await fetch(forced: true) } }
            .navigationTitle("Riders Gallery")
            .onAppear { Task { await fetch() } }
        }
    }

    func fetch(forced: Bool = false) async {
        let action = forced ? GalleryAction.forcedFetchRequested : .fetchRequested
        await store.send(action) {
            if store.loadInProgress == .loadPending {
                do {
                    let names = try await store.state.fetchNames()
                    await store.send(.fetchResults(names))
                } catch {
                    await store.send(.fetchError(error.localizedDescription))
                }
            }
        }
    }
}

extension String {
    func endsInJpg() -> Bool {
        return !self.ranges(of: /\.[jJ][pP][eE]?[gG]$/).isEmpty
    }
}
