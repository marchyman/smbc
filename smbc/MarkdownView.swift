//
// Copyright 2024 Marco S Hyman
// See LICENSE file for info
// https://www.snafu.org/
//

import MarkdownUI
import SwiftUI

struct MarkdownView: View {
    @Environment(ProgramState.self) var state

    let name: String

    @State private var markdown: String? = nil

    var body: some View {
        VStack {
            if let markdown {
                Markdown(markdown)
                    .padding(.horizontal)
            } else {
                Image(systemName: "circle.hexagongrid.fill")
                    .symbolEffect(.pulse, options: .repeating)
            }
        }
        .frame(height: 300, alignment: .top)
        .clipped()
        .task {
            markdown = try? await state.galleryModel.fetchStart(mdFile: name)
        }
    }
}

#Preview {
    MarkdownView(name: "riders/2024/0526/index.md")
        .environment(ProgramState())
        .frame(height: 300)
}
