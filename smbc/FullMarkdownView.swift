//
// Copyright 2024 Marco S Hyman
// See LICENSE file for info
// https://www.snafu.org/
//

import MarkdownUI
import SwiftUI

struct FullMarkdownView: View {
    @Environment(ProgramState.self) var state

    let name: String

    @State private var markdown: String? = nil

    var body: some View {
       ScrollView  {
            if let markdown {
                Markdown(markdown)
                    .padding(.horizontal)
            } else {
                Image(systemName: "circle.hexagongrid.fill")
                    .symbolEffect(.pulse, options: .repeating)
            }
        }
        .padding(.horizontal)
        .task {
            markdown = try? await state.galleryModel.fetch(mdFile: name)
        }
    }
}

#Preview {
    FullMarkdownView(name: "riders/2024/0526/index.md")
        .environment(ProgramState())
        .frame(height: 300)
}
