//
// Copyright 2024 Marco S Hyman
// https://www.snafu.org/
//

import MarkdownUI
import SwiftUI

struct MarkdownView: View {
    let name: String

    @State private var markdown: String?

    var body: some View {
        VStack {
            if let markdown {
                Markdown(markdown)
                    .padding(.horizontal)
            } else {
                Spacer()
                Image(systemName: "circle.hexagongrid.fill")
                    .symbolEffect(.pulse, options: .repeating)
                    .frame(maxWidth: .infinity)
            }
            Spacer()
        }
        .frame(height: 270, alignment: .top)
        .overlay {
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.secondary, lineWidth: 2)
        }
        .padding(.horizontal)
        .clipped()
        .task {
            markdown = try? await GalleryModel.fetchMarkdown(mdFile: name, start: true)
        }
    }
}
