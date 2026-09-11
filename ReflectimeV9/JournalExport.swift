import SwiftUI
import UniformTypeIdentifiers

struct JournalMarkdownDocument: FileDocument {
    static var readableContentTypes: [UTType] {
        [UTType(filenameExtension: "md") ?? .plainText, .plainText, .text]
    }

    var text: String

    init(text: String) {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(data: data, encoding: .utf8) ?? ""
        } else {
            text = ""
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }

    static func markdown(from reflections: [Reflection]) -> String {
        let sorted = reflections.sorted { $0.createdAt > $1.createdAt }
        var lines = [
            "# Reflectime",
            "",
            "Exported \(Date.now.formatted(date: .complete, time: .shortened))",
            "\(sorted.count) reflection\(sorted.count == 1 ? "" : "s")",
            ""
        ]
        for item in sorted {
            lines.append(item.markdown)
            lines.append("")
            lines.append("---")
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }
}
