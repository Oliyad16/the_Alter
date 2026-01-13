//
//  MyHighlightsView.swift
//  The Alter beta 2
//
//  View and filter highlights by category with export functionality
//

import SwiftUI

struct MyHighlightsView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedCategories: Set<HighlightCategory> = []
    @State private var searchText = ""
    @State private var sortOption: HighlightSortOption = .newest
    @State private var showExportSheet = false

    private var allHighlights: [VerseAction] {
        dataStore.getHighlights()
    }

    private var categoryStats: [HighlightCategory: Int] {
        dataStore.getHighlightCategoryStats()
    }

    private var filteredHighlights: [VerseAction] {
        var highlights = allHighlights

        // Filter by selected categories
        if !selectedCategories.isEmpty {
            highlights = highlights.filter { highlight in
                if let category = highlight.highlightCategory {
                    return selectedCategories.contains(category)
                }
                return selectedCategories.contains(.general)
            }
        }

        // Filter by search text
        if !searchText.isEmpty {
            highlights = highlights.filter { highlight in
                highlight.verseId.localizedCaseInsensitiveContains(searchText) ||
                (highlight.content?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        // Sort
        switch sortOption {
        case .newest:
            highlights.sort { $0.createdAt > $1.createdAt }
        case .oldest:
            highlights.sort { $0.createdAt < $1.createdAt }
        case .byCategory:
            highlights.sort { ($0.highlightCategory?.rawValue ?? "zzz") < ($1.highlightCategory?.rawValue ?? "zzz") }
        case .bibleOrder:
            highlights.sort { compareVerseIds($0.verseId, $1.verseId) }
        }

        return highlights
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.5))

                TextField("Search highlights...", text: $searchText)
                    .foregroundColor(.white)
                    .accentColor(.altarOrange)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 16)

            // Category Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // "All" chip
                    Button(action: {
                        if selectedCategories.isEmpty {
                            // Already showing all
                        } else {
                            selectedCategories.removeAll()
                        }
                        HapticManager.shared.trigger(.light)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.grid.2x2.fill")
                                .font(.caption)
                            Text("All")
                                .font(.caption.weight(.semibold))
                            Text("(\(allHighlights.count))")
                                .font(.caption2)
                                .opacity(0.7)
                        }
                        .foregroundColor(selectedCategories.isEmpty ? .black : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedCategories.isEmpty ? Color.altarYellow : Color.white.opacity(0.1))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(selectedCategories.isEmpty ? Color.clear : Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }

                    ForEach(HighlightCategory.allCases) { category in
                        let count = categoryStats[category] ?? 0
                        let isSelected = selectedCategories.contains(category)

                        Button(action: {
                            if isSelected {
                                selectedCategories.remove(category)
                            } else {
                                selectedCategories.insert(category)
                            }
                            HapticManager.shared.trigger(.light)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .font(.caption)
                                Text(category.rawValue)
                                    .font(.caption.weight(.semibold))
                                Text("(\(count))")
                                    .font(.caption2)
                                    .opacity(0.7)
                            }
                            .foregroundColor(isSelected ? .black : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isSelected ? category.iconColor : Color.white.opacity(0.1))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isSelected ? Color.clear : Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .opacity(count > 0 ? 1.0 : 0.5)
                        .disabled(count == 0)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }

            // Sort Options
            HStack {
                Text("Sort:")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.6))

                Picker("Sort", selection: $sortOption) {
                    ForEach(HighlightSortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .accentColor(.altarOrange)

                Spacer()

                Button(action: {
                    showExportSheet = true
                    HapticManager.shared.trigger(.medium)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.altarOrange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.altarOrange.opacity(0.15))
                    .cornerRadius(8)
                }
                .disabled(filteredHighlights.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom, 12)

            Divider()
                .background(Color.white.opacity(0.1))

            // Highlights List
            if filteredHighlights.isEmpty {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: selectedCategories.isEmpty && searchText.isEmpty ? "highlighter" : "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.3))

                    Text(emptyStateMessage)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding()

                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredHighlights) { highlight in
                            HighlightCard(highlight: highlight)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("My Highlights")
        .altarTitleInline()
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showExportSheet) {
            ExportHighlightsSheet(highlights: filteredHighlights)
        }
    }

    private var emptyStateMessage: String {
        if !searchText.isEmpty {
            return "No highlights match '\(searchText)'"
        } else if !selectedCategories.isEmpty {
            return "No highlights in selected categories"
        } else {
            return "No highlights yet\nStart highlighting verses in the Bible!"
        }
    }

    private func compareVerseIds(_ id1: String, _ id2: String) -> Bool {
        // Simple comparison for Bible order
        // Format: "BOOK.CHAPTER.VERSE"
        let parts1 = id1.split(separator: ".").map { String($0) }
        let parts2 = id2.split(separator: ".").map { String($0) }

        // Compare book
        if parts1[0] != parts2[0] {
            return parts1[0] < parts2[0]
        }

        // Compare chapter
        if let ch1 = Int(parts1[1]), let ch2 = Int(parts2[1]), ch1 != ch2 {
            return ch1 < ch2
        }

        // Compare verse
        if let v1 = Int(parts1[2]), let v2 = Int(parts2[2]) {
            return v1 < v2
        }

        return false
    }
}

enum HighlightSortOption: String, CaseIterable, Identifiable {
    case newest = "Newest"
    case oldest = "Oldest"
    case byCategory = "Category"
    case bibleOrder = "Bible Order"

    var id: String { rawValue }
}

// MARK: - Highlight Card

struct HighlightCard: View {
    @EnvironmentObject var dataStore: AppDataStore
    let highlight: VerseAction

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Verse ID + Category Badge
            HStack {
                HStack(spacing: 6) {
                    Text(highlight.verseId)
                        .font(.caption.weight(.bold))
                        .foregroundColor(.altarOrange)

                    if let category = highlight.highlightCategory {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.caption2)
                            Text(category.rawValue)
                                .font(.caption2.weight(.semibold))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(category.iconColor)
                        .cornerRadius(6)
                    }
                }

                Spacer()

                // Color indicator
                Circle()
                    .fill(highlight.highlightColor?.color ?? .yellow)
                    .frame(width: 12, height: 12)
            }

            // Verse Content
            if let content = highlight.content {
                Text(content)
                    .font(.body.italic())
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(4)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill((highlight.highlightColor?.color ?? .yellow).opacity(0.2))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke((highlight.highlightColor?.color ?? .yellow).opacity(0.4), lineWidth: 1)
                    )
            }

            // Footer: Date
            Text(highlight.createdAt, style: .date)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Export Sheet

struct ExportHighlightsSheet: View {
    @Environment(\.dismiss) var dismiss
    let highlights: [VerseAction]

    @State private var selectedFormat: ExportFormat = .text
    @State private var showShareSheet = false
    @State private var exportedContent = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Format Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Export Format")
                        .font(.headline)
                        .foregroundColor(.white)

                    ForEach(ExportFormat.allCases) { format in
                        Button(action: {
                            selectedFormat = format
                            HapticManager.shared.trigger(.light)
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(format.name)
                                        .font(.body.weight(.semibold))
                                        .foregroundColor(.white)
                                    Text(format.description)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }

                                Spacer()

                                if selectedFormat == format {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.altarSuccess)
                                }
                            }
                            .padding()
                            .background(selectedFormat == format ? Color.altarOrange.opacity(0.2) : Color.white.opacity(0.06))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedFormat == format ? Color.altarOrange : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }

                Spacer()

                // Export Button
                Button(action: {
                    exportedContent = generateExport()
                    showShareSheet = true
                    HapticManager.shared.trigger(.medium)
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export \(highlights.count) Highlights")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.altarGradientStart, .altarGradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Export Highlights")
            .altarTitleInline()
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [exportedContent])
            }
        }
    }

    private func generateExport() -> String {
        switch selectedFormat {
        case .text:
            return generateTextExport()
        case .markdown:
            return generateMarkdownExport()
        case .json:
            return generateJSONExport()
        }
    }

    private func generateTextExport() -> String {
        var output = "MY HIGHLIGHTS\n"
        output += "Generated: \(Date().formatted(date: .long, time: .shortened))\n"
        output += "Total: \(highlights.count) highlights\n"
        output += String(repeating: "=", count: 50) + "\n\n"

        for highlight in highlights {
            output += "\(highlight.verseId)\n"
            if let category = highlight.highlightCategory {
                output += "Category: \(category.rawValue)\n"
            }
            if let content = highlight.content {
                output += "\"\(content)\"\n"
            }
            output += "Highlighted: \(highlight.createdAt.formatted(date: .abbreviated, time: .omitted))\n"
            output += "\n" + String(repeating: "-", count: 50) + "\n\n"
        }

        return output
    }

    private func generateMarkdownExport() -> String {
        var output = "# My Highlights\n\n"
        output += "*Generated: \(Date().formatted(date: .long, time: .shortened))*\n\n"
        output += "**Total: \(highlights.count) highlights**\n\n"
        output += "---\n\n"

        for highlight in highlights {
            output += "### \(highlight.verseId)\n\n"
            if let category = highlight.highlightCategory {
                output += "**Category:** \(category.rawValue)\n\n"
            }
            if let content = highlight.content {
                output += "> \(content)\n\n"
            }
            output += "*Highlighted: \(highlight.createdAt.formatted(date: .abbreviated, time: .omitted))*\n\n"
            output += "---\n\n"
        }

        return output
    }

    private func generateJSONExport() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let exportData = highlights.map { highlight in
            [
                "verseId": highlight.verseId,
                "content": highlight.content ?? "",
                "color": highlight.highlightColor?.rawValue ?? "",
                "category": highlight.highlightCategory?.rawValue ?? "",
                "createdAt": ISO8601DateFormatter().string(from: highlight.createdAt)
            ]
        }

        if let jsonData = try? encoder.encode(exportData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }

        return "[]"
    }
}

enum ExportFormat: String, CaseIterable, Identifiable {
    case text = "text"
    case markdown = "markdown"
    case json = "json"

    var id: String { rawValue }

    var name: String {
        switch self {
        case .text: return "Plain Text"
        case .markdown: return "Markdown"
        case .json: return "JSON"
        }
    }

    var description: String {
        switch self {
        case .text: return "Simple text format, great for sharing"
        case .markdown: return "Formatted text with headers and quotes"
        case .json: return "Structured data for importing elsewhere"
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
