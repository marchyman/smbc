//
// Copyright 2024 Marco S Hyman
// See LICENSE file for info
// https://www.snafu.org/
//

import MarkdownUI
import SwiftUI

struct MarkdownView: View {
    @Environment(ProgramState.self) var state
    @Environment(\.colorScheme) private var colorScheme: ColorScheme

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
            Spacer()
            HStack {
                Spacer()
                Text("**more**...")
                    .font(.footnote)
                    .padding(.trailing)
            }
        }
        .frame(height: 300, alignment: .top)
        .overlay {
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.secondary, lineWidth: 2)
        }
        .padding(.horizontal)
        .clipped()
        .task {
            markdown = try? await GalleryModel.fetch(mdFile: name,
                                                     start: true)
        }
    }
}

#Preview {
    MarkdownView(name: "riders/2024/0526/index.md")
        .environment(ProgramState())
        .frame(height: 300)
}
