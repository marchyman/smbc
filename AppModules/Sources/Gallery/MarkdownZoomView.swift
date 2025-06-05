//
// Copyright 2024 Marco S Hyman
// https://www.snafu.org/
//

import MarkdownUI
import SwiftUI
import ViewModifiers

struct MarkdownZoomView: View {
    let name: String

    @State private var markdown: String?

    var body: some View {
        ScrollView {
            if let markdown {
                Markdown(markdown)
                    .padding(.horizontal)
            } else {
                VStack {
                    Spacer()
                    Image(systemName: "circle.hexagongrid.fill")
                        .symbolEffect(.pulse, options: .repeating)
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 300)
            }
        }
        .padding(.horizontal)
        .smbcBackground()
        .task {
            markdown = try? await GalleryModel.fetchMarkdown(mdFile: name)
        }
    }
}
