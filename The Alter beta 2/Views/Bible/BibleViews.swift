import SwiftUI

// MARK: - Bible Reader Main View (Bold & Expressive)
struct BibleReaderView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @ObservedObject private var bibleAPI = BibleAPIManager.shared
    @State private var books: [BibleBook] = []
    @State private var selectedBook: BibleBook?
    @State private var selectedChapter: BibleChapterContent?
    @State private var currentChapterNumber: Int = 1
    @State private var showBookPicker = false
    @State private var showTranslationPicker = false
    @State private var showSearch = false
    @State private var showVersePicker = false
    @State private var hasAppeared = false
    @State private var isContinuousMode = false
    @State private var loadedChapters: [Int: BibleChapterContent] = [:]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if bibleAPI.isLoading {
                    BoldLoadingView()
                } else if let error = bibleAPI.error {
                    BoldErrorView(error: error) { loadBooks() }
                } else if let chapter = selectedChapter, let book = selectedBook {
                    if isContinuousMode {
                        ContinuousScrollBibleView(
                            currentBook: book,
                            currentChapterNumber: $currentChapterNumber,
                            loadedChapters: $loadedChapters,
                            maxChapterNumber: maxChapterNumber,
                            translationName: bibleAPI.currentBibleName,
                            highlightedVerses: getHighlightedVerses(),
                            onMarkComplete: { chapterNum in
                                if let chap = loadedChapters[chapterNum] {
                                    markChapterComplete(chap)
                                }
                            },
                            onHighlight: { verseId, content in
                                toggleHighlight(verseId: verseId, content: content)
                            },
                            onLoadChapter: { chapterNum in
                                loadChapterForContinuousMode(book: book, chapterNumber: chapterNum)
                            }
                        )
                    } else {
                        BoldChapterContentView(
                            chapter: chapter,
                            bookName: book.name,
                            currentChapterNumber: currentChapterNumber,
                            maxChapterNumber: maxChapterNumber,
                            translationName: bibleAPI.currentBibleName,
                            highlightedVerses: getHighlightedVerses(),
                            onMarkComplete: {
                                markChapterComplete(chapter)
                                // Auto-advance to next chapter
                                if currentChapterNumber < maxChapterNumber {
                                    navigateChapter(delta: 1)
                                }
                            },
                            onPreviousChapter: { navigateChapter(delta: -1) },
                            onNextChapter: { navigateChapter(delta: 1) },
                            onHighlight: { verseId, content in
                                toggleHighlight(verseId: verseId, content: content)
                            },
                            onPrayLater: { verseId, content in
                                dataStore.addVerseAction(verseId: verseId, action: .prayLater, content: content)
                                HapticManager.shared.trigger(.medium)
                            }
                        )
                    }
                } else {
                    BoldEmptyBibleView(
                        onChooseBook: { showBookPicker = true },
                        recentBooks: getRecentBooks(),
                        onSelectRecent: { book in
                            selectedBook = book
                            currentChapterNumber = getLastReadChapter(book: book.name) ?? 1
                            loadChapter(book: book, chapterNumber: currentChapterNumber)
                        }
                    )
                    .opacity(hasAppeared ? 1 : 0)
                    .animation(AltarAnimations.gentle, value: hasAppeared)
                }
            }
            .navigationTitle("Read")
            .preferredColorScheme(.dark)
            .toolbar {
                if selectedChapter != nil {
                    ToolbarItem(placement: .altarLeading) {
                        // Translation selector - More prominent
                        Button(action: { showTranslationPicker = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "globe")
                                    .font(.callout)
                                Text(bibleAPI.currentBibleName)
                                    .font(.headline.weight(.bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(
                                    colors: [Color.altarRed.opacity(0.3), Color.altarOrange.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.altarSoftGold.opacity(0.4), lineWidth: 1)
                            )
                        }
                    }

                    ToolbarItemGroup(placement: .altarTrailing) {
                        // Search button
                        Button(action: { showSearch = true }) {
                            Image(systemName: "magnifyingglass")
                                .font(.title3)
                                .foregroundColor(.altarSoftGold)
                        }

                        // Continuous scroll toggle
                        Button(action: {
                            isContinuousMode.toggle()
                            HapticManager.shared.trigger(.light)
                        }) {
                            Image(systemName: isContinuousMode ? "scroll.fill" : "scroll")
                                .font(.title3)
                                .foregroundColor(.altarSoftGold)
                        }

                        // Verse picker button
                        Button(action: { showVersePicker = true }) {
                            Image(systemName: "list.number")
                                .font(.title3)
                                .foregroundColor(.altarSoftGold)
                        }

                        // Book picker
                        Button(action: { showBookPicker = true }) {
                            Image(systemName: "book.fill")
                                .font(.title3)
                                .foregroundColor(.altarSoftGold)
                        }
                    }
                }
            }
            .sheet(isPresented: $showBookPicker) {
                BoldBookPickerView(books: books) { book in
                    selectedBook = book
                    currentChapterNumber = 1
                    loadChapter(book: book, chapterNumber: 1)
                    showBookPicker = false
                }
            }
            .sheet(isPresented: $showSearch) {
                BibleSearchView()
            }
            .sheet(isPresented: $showTranslationPicker) {
                TranslationPickerView(
                    availableBibles: bibleAPI.availableBibles,
                    currentBibleId: bibleAPI.currentBibleId,
                    onSelect: { bibleId, name in
                        bibleAPI.setBibleVersion(bibleId, name: name)
                        // Reload current chapter with new translation
                        if let book = selectedBook {
                            loadChapter(book: book, chapterNumber: currentChapterNumber)
                        } else {
                            loadBooks()
                        }
                        showTranslationPicker = false
                    }
                )
            }
            .sheet(isPresented: $showVersePicker) {
                if let chapter = selectedChapter {
                    VersePickerSheet(
                        parsedVerses: parseVersesFromChapter(chapter.content),
                        currentVerse: nil,
                        onSelectVerse: { verseNum in
                            // For now, just dismiss. ScrollViewReader integration would be needed for scrolling
                            showVersePicker = false
                        }
                    )
                }
            }
            .onChange(of: isContinuousMode) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "bible.continuousScrollMode")
            }
            .onAppear {
                hasAppeared = true
                if books.isEmpty { loadBooks() }
                // Load continuous mode preference
                isContinuousMode = UserDefaults.standard.bool(forKey: "bible.continuousScrollMode")
            }
        }
    }

    private func loadBooks() {
        bibleAPI.fetchBooks { result in
            if case .success(let fetchedBooks) = result { books = fetchedBooks }
        }
    }

    private func loadChapter(book: BibleBook, chapterNumber: Int) {
        let chapterId = "\(book.id).\(chapterNumber)"
        if let cached = bibleAPI.getCachedChapter(chapterId: chapterId) {
            selectedChapter = cached
            loadedChapters[chapterNumber] = cached
            return
        }
        bibleAPI.fetchChapter(chapterId: chapterId) { result in
            switch result {
            case .success(let chapter):
                self.selectedChapter = chapter
                self.loadedChapters[chapterNumber] = chapter
                bibleAPI.cacheChapter(chapter)
            case .failure(let error):
                // Error is already set in BibleAPIManager, but we can handle it here if needed
                print("Failed to load chapter: \(error.localizedDescription)")
            }
        }
    }

    private func loadChapterForContinuousMode(book: BibleBook, chapterNumber: Int) {
        let chapterId = "\(book.id).\(chapterNumber)"
        // Check if already loaded
        if loadedChapters[chapterNumber] != nil {
            return
        }
        // Try cache first
        if let cached = bibleAPI.getCachedChapter(chapterId: chapterId) {
            loadedChapters[chapterNumber] = cached
            return
        }
        // Fetch from API
        bibleAPI.fetchChapter(chapterId: chapterId) { result in
            switch result {
            case .success(let chapter):
                self.loadedChapters[chapterNumber] = chapter
                self.bibleAPI.cacheChapter(chapter)
            case .failure(let error):
                print("Failed to load chapter \(chapterNumber): \(error.localizedDescription)")
            }
        }
    }

    private var maxChapterNumber: Int {
        guard let book = selectedBook else {
            return 50 // Default fallback when no book is selected
        }
        
        if let chapters = book.chapters, !chapters.isEmpty {
            return chapters.count
        }
        
        // Fallback: use common max chapter counts if chapters array is not available
        return getMaxChaptersForBook(book.name)
    }
    
    private func getMaxChaptersForBook(_ bookName: String) -> Int {
        // Standard chapter counts for each book
        let chapterCounts: [String: Int] = [
            "Genesis": 50, "Exodus": 40, "Leviticus": 27, "Numbers": 36, "Deuteronomy": 34,
            "Joshua": 24, "Judges": 21, "Ruth": 4, "1 Samuel": 31, "2 Samuel": 24,
            "1 Kings": 22, "2 Kings": 25, "1 Chronicles": 29, "2 Chronicles": 36,
            "Ezra": 10, "Nehemiah": 13, "Esther": 10, "Job": 42, "Psalms": 150,
            "Proverbs": 31, "Ecclesiastes": 12, "Song of Solomon": 8, "Isaiah": 66,
            "Jeremiah": 52, "Lamentations": 5, "Ezekiel": 48, "Daniel": 12,
            "Hosea": 14, "Joel": 3, "Amos": 9, "Obadiah": 1, "Jonah": 4,
            "Micah": 7, "Nahum": 3, "Habakkuk": 3, "Zephaniah": 3, "Haggai": 2,
            "Zechariah": 14, "Malachi": 4,
            "Matthew": 28, "Mark": 16, "Luke": 24, "John": 21, "Acts": 28,
            "Romans": 16, "1 Corinthians": 16, "2 Corinthians": 13, "Galatians": 6,
            "Ephesians": 6, "Philippians": 4, "Colossians": 4, "1 Thessalonians": 5,
            "2 Thessalonians": 3, "1 Timothy": 6, "2 Timothy": 4, "Titus": 3,
            "Philemon": 1, "Hebrews": 13, "James": 5, "1 Peter": 5, "2 Peter": 3,
            "1 John": 5, "2 John": 1, "3 John": 1, "Jude": 1, "Revelation": 22
        ]
        return chapterCounts[bookName] ?? 50 // Default fallback
    }

    private func navigateChapter(delta: Int) {
        guard let book = selectedBook else { return }
        let newChapter = currentChapterNumber + delta
        let maxChapter = maxChapterNumber
        
        guard newChapter >= 1 && newChapter <= maxChapter else { return }

        currentChapterNumber = newChapter
        loadChapter(book: book, chapterNumber: newChapter)
        HapticManager.shared.trigger(.light)
    }

    private func markChapterComplete(_ chapter: BibleChapterContent) {
        guard let book = selectedBook else { return }
        dataStore.markChapterComplete(book: book.name, chapter: Int(chapter.number) ?? 1)
        HapticManager.shared.trigger(.medium)
    }
    
    private func getHighlightedVerses() -> Set<String> {
        Set(dataStore.verseActions
            .filter { $0.action == .highlight }
            .map { $0.verseId })
    }
    
    private func toggleHighlight(verseId: String, content: String) {
        let highlightedVerses = getHighlightedVerses()
        if highlightedVerses.contains(verseId) {
            // Remove highlight
            dataStore.removeVerseAction(verseId: verseId, action: .highlight)
        } else {
            // Add highlight
            dataStore.addVerseAction(verseId: verseId, action: .highlight, content: content)
        }
        HapticManager.shared.trigger(.light)
    }
    
    private func getRecentBooks() -> [BibleBook] {
        // Get recently read books from progress
        let progress = dataStore.bibleProgress
        let uniqueBookNames = Array(Set(progress.map { $0.book }))
        let recentBookNames = uniqueBookNames.sorted { book1, book2 in
            let book1Progress = progress.filter { $0.book == book1 }
            let book2Progress = progress.filter { $0.book == book2 }
            let book1Date = book1Progress.max(by: { $0.completedAt < $1.completedAt })?.completedAt ?? .distantPast
            let book2Date = book2Progress.max(by: { $0.completedAt < $1.completedAt })?.completedAt ?? .distantPast
            return book1Date > book2Date
        }
        let recentBookSet = Set(recentBookNames.prefix(5))
        return books.filter { recentBookSet.contains($0.name) }
    }
    
    private func getLastReadChapter(book: String) -> Int? {
        let bookProgress = dataStore.bibleProgress.filter { $0.book == book }
        return bookProgress.max(by: { $0.completedAt < $1.completedAt })?.chapter
    }

    private func parseVersesFromChapter(_ content: String) -> [(verseNumber: Int, text: String)] {
        // Remove HTML tags first
        var cleaned = content.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        cleaned = cleaned.replacingOccurrences(of: "&nbsp;", with: " ")
        cleaned = cleaned.replacingOccurrences(of: "&amp;", with: "&")
        cleaned = cleaned.replacingOccurrences(of: "&quot;", with: "\"")

        // Match verse patterns: [1] verse text or (1) verse text
        let pattern = "\\[(\\d+)\\]\\s*([^\\[\\]]+?)(?=\\[\\d+\\]|$)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }

        let matches = regex.matches(in: cleaned, range: NSRange(cleaned.startIndex..., in: cleaned))
        var verses: [(verseNumber: Int, text: String)] = []

        for match in matches {
            if let verseNumRange = Range(match.range(at: 1), in: cleaned),
               let textRange = Range(match.range(at: 2), in: cleaned),
               let verseNum = Int(cleaned[verseNumRange]) {
                let text = String(cleaned[textRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                verses.append((verseNumber: verseNum, text: text))
            }
        }

        return verses
    }
}

// MARK: - Bold Loading View
struct BoldLoadingView: View {
    @State private var rotation: Double = 0

    var body: some View {
        VStack(spacing: AltarSpacing.large) {
            ZStack {
                Circle()
                    .stroke(Color.altarSoftGold.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(Color.altarSoftGold, lineWidth: 4)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(rotation))
            }

            Text("Loading Scripture...")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Bold Error View
struct BoldErrorView: View {
    let error: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: AltarSpacing.large) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 64))
                .foregroundColor(.altarSoftGold.opacity(0.6))
                .boldGlow(radius: 20)

            VStack(spacing: AltarSpacing.small) {
                Text("Unable to load Bible")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)

                Text(error)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button(action: onRetry) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
            }
            .buttonStyle(AltarBoldButtonStyle())
            .padding(.top)
        }
        .padding()
    }
}

// MARK: - Bold Empty Bible View
struct BoldEmptyBibleView: View {
    let onChooseBook: () -> Void
    let recentBooks: [BibleBook]
    let onSelectRecent: (BibleBook) -> Void
    @State private var glowAmount: CGFloat = 0.3

    var body: some View {
        ScrollView {
            VStack(spacing: AltarSpacing.extraLarge) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.altarSoftGold)
                    .shadow(color: .altarSoftGold.opacity(glowAmount), radius: 30, x: 0, y: 0)
                    .onAppear {
                        withAnimation(AltarAnimations.glowPulse) {
                            glowAmount = 0.6
                        }
                    }

                VStack(spacing: AltarSpacing.small) {
                    Text("Begin Reading")
                        .font(.title.weight(.bold))
                        .foregroundColor(.white)

                    Text("Select a book to start your journey")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                // Recent books section
                if !recentBooks.isEmpty {
                    VStack(alignment: .leading, spacing: AltarSpacing.medium) {
                        Text("Continue Reading")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ForEach(recentBooks) { book in
                            Button(action: { onSelectRecent(book) }) {
                                HStack {
                                    Image(systemName: "bookmark.fill")
                                        .foregroundColor(.altarSoftGold)
                                    Text(book.name)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                .padding()
                                .background(Color.white.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                        }
                    }
                }

                Button(action: onChooseBook) {
                    HStack {
                        Image(systemName: "book.fill")
                        Text("Choose Book")
                    }
                }
                .buttonStyle(AltarBoldButtonStyle())
            }
            .padding()
        }
    }
}

// MARK: - Bold Chapter Content View
struct BoldChapterContentView: View {
    let chapter: BibleChapterContent
    let bookName: String
    let currentChapterNumber: Int
    let maxChapterNumber: Int
    let translationName: String
    let highlightedVerses: Set<String>
    let onMarkComplete: () -> Void
    let onPreviousChapter: () -> Void
    let onNextChapter: () -> Void
    let onHighlight: (String, String) -> Void
    let onPrayLater: (String, String) -> Void
    @State private var hasAppeared = false
    @State private var selectedVerseId: String?
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AltarSpacing.large) {
                // Chapter Header
                VStack(alignment: .leading, spacing: AltarSpacing.small) {
                    Text(chapter.reference)
                        .font(.title.weight(.bold))
                        .foregroundColor(.white)
                    
                    // Translation badge
                    HStack(spacing: 8) {
                        Image(systemName: "textformat")
                            .font(.caption2)
                            .foregroundColor(.altarSoftGold.opacity(0.7))
                        Text(translationName)
                            .font(.caption.weight(.medium))
                            .foregroundColor(.altarSoftGold.opacity(0.9))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.altarSoftGold.opacity(0.15))
                    .cornerRadius(8)

                    HStack {
                        if let verseCount = chapter.verseCount {
                            Text("\(verseCount) verses")
                                .font(.caption)
                                .foregroundColor(.altarSoftGold)
                        }

                        Spacer()

                        // Chapter navigation
                        HStack(spacing: AltarSpacing.medium) {
                            Button(action: onPreviousChapter) {
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                                    .foregroundColor(currentChapterNumber > 1 ? .altarSoftGold : .white.opacity(0.3))
                            }
                            .disabled(currentChapterNumber <= 1)

                            Text("Ch. \(currentChapterNumber)")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.white.opacity(0.6))

                            Button(action: onNextChapter) {
                                Image(systemName: "chevron.right")
                                    .font(.headline)
                                    .foregroundColor(currentChapterNumber < maxChapterNumber ? .altarSoftGold : .white.opacity(0.3))
                            }
                            .disabled(currentChapterNumber >= maxChapterNumber)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .opacity(hasAppeared ? 1 : 0)
                .animation(AltarAnimations.gentle, value: hasAppeared)

                // Scripture content with verse highlighting
                VerseContentView(
                    content: chapter.content,
                    bookId: chapter.id.components(separatedBy: ".").first ?? "",
                    chapterNumber: currentChapterNumber,
                    highlightedVerses: highlightedVerses,
                    onVerseTap: { verseId, content in
                        onHighlight(verseId, content)
                    }
                )
                .padding(.horizontal)
                .opacity(hasAppeared ? 1 : 0)
                .animation(AltarAnimations.gentle.delay(0.1), value: hasAppeared)

                // Mark complete button
                Button(action: onMarkComplete) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Mark Chapter Complete")
                    }
                    .font(.headline.weight(.semibold))
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
                    .cornerRadius(16)
                    .shadow(color: .altarSoftGold.opacity(0.3), radius: 10, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.bottom, AltarSpacing.extraLarge)
                .opacity(hasAppeared ? 1 : 0)
                .animation(AltarAnimations.gentle.delay(0.2), value: hasAppeared)
            }
        }
        .offset(x: dragOffset)
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    // Only allow horizontal drag
                    if abs(value.translation.width) > abs(value.translation.height) {
                        dragOffset = value.translation.width
                        isDragging = true
                    }
                }
                .onEnded { value in
                    let threshold: CGFloat = 100
                    if value.translation.width > threshold && currentChapterNumber > 1 {
                        // Swipe right -> previous chapter
                        HapticManager.shared.trigger(.medium)
                        withAnimation(.spring()) { dragOffset = UIScreen.main.bounds.width }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onPreviousChapter()
                            dragOffset = 0
                            isDragging = false
                        }
                    } else if value.translation.width < -threshold && currentChapterNumber < maxChapterNumber {
                        // Swipe left -> next chapter
                        HapticManager.shared.trigger(.medium)
                        withAnimation(.spring()) { dragOffset = -UIScreen.main.bounds.width }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onNextChapter()
                            dragOffset = 0
                            isDragging = false
                        }
                    } else {
                        // Reset if swipe didn't meet threshold
                        withAnimation(.spring()) {
                            dragOffset = 0
                            isDragging = false
                        }
                    }
                }
        )
        .onAppear { hasAppeared = true }
    }

    private func parseChapterContent(_ content: String) -> String {
        // Remove HTML tags
        var cleaned = content.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // Decode common HTML entities
        cleaned = cleaned.replacingOccurrences(of: "&nbsp;", with: " ")
        cleaned = cleaned.replacingOccurrences(of: "&amp;", with: "&")
        cleaned = cleaned.replacingOccurrences(of: "&lt;", with: "<")
        cleaned = cleaned.replacingOccurrences(of: "&gt;", with: ">")
        cleaned = cleaned.replacingOccurrences(of: "&quot;", with: "\"")
        cleaned = cleaned.replacingOccurrences(of: "&#39;", with: "'")
        
        // Clean up extra whitespace
        cleaned = cleaned.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned
    }
}

// MARK: - Verse Content View with Highlighting
struct VerseContentView: View {
    @EnvironmentObject var dataStore: AppDataStore
    let content: String
    let bookId: String
    let chapterNumber: Int
    let highlightedVerses: Set<String>
    let onVerseTap: (String, String) -> Void
    @State private var selectedVerse: (id: String, text: String)?
    @State private var showVerseActions = false

    private var parsedVerses: [(verseNumber: Int, text: String)] {
        parseVerses(from: content)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(parsedVerses, id: \.verseNumber) { verse in
                let verseId = "\(bookId).\(chapterNumber).\(verse.verseNumber)"
                let highlight = dataStore.getHighlightForVerse(verseId: verseId)
                let hasNotes = !dataStore.getNotesForVerse(verseId: verseId).isEmpty

                HStack(alignment: .top, spacing: 8) {
                    VStack(spacing: 4) {
                        Text("\(verse.verseNumber)")
                            .font(.system(size: 14, weight: .semibold, design: .serif))
                            .foregroundColor(.altarSoftGold.opacity(0.7))

                        if hasNotes {
                            Image(systemName: "note.text")
                                .font(.system(size: 10))
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(width: 30, alignment: .trailing)

                    Text(verse.text)
                        .font(.system(size: dataStore.bibleFontSize, weight: .regular, design: .serif))
                        .lineSpacing(dataStore.bibleLineSpacing)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.vertical, 4)
                        .padding(.horizontal, highlight != nil ? 8 : 0)
                        .background(
                            highlight != nil
                                ? (highlight?.highlightColor?.color ?? Color.yellow).opacity(0.45)
                                : Color.clear
                        )
                        .cornerRadius(6)
                        .overlay(
                            highlight != nil
                                ? RoundedRectangle(cornerRadius: 6)
                                    .stroke((highlight?.highlightColor?.color ?? Color.yellow).opacity(0.5), lineWidth: 1.5)
                                : nil
                        )
                        .shadow(
                            color: highlight != nil
                                ? (highlight?.highlightColor?.color ?? Color.clear).opacity(0.2)
                                : Color.clear,
                            radius: 3,
                            x: 0,
                            y: 1
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedVerse = (verseId, verse.text)
                            HapticManager.shared.trigger(.light)
                            showVerseActions = true
                        }
                        .onLongPressGesture(minimumDuration: 0.5) {
                            selectedVerse = (verseId, verse.text)
                            HapticManager.shared.trigger(.medium)
                            showVerseActions = true
                        }
                }
            }
        }
        .sheet(isPresented: $showVerseActions) {
            if let verse = selectedVerse {
                UnifiedVerseActionsSheet(verseId: verse.id, verseText: verse.text)
            }
        }
    }
    
    private func parseVerses(from content: String) -> [(verseNumber: Int, text: String)] {
        // Parse HTML content to extract verse numbers and text
        // The API returns content with verse numbers embedded
        var verses: [(verseNumber: Int, text: String)] = []
        
        // Remove HTML tags but preserve verse numbers
        let cleaned = content.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // Pattern to match verse numbers (e.g., "1 ", "2 ", etc.)
        let pattern = "\\b(\\d+)\\s+"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsString = cleaned as NSString
        let matches = regex?.matches(in: cleaned, options: [], range: NSRange(location: 0, length: nsString.length)) ?? []
        
        for (index, match) in matches.enumerated() {
            if let verseRange = Range(match.range, in: cleaned),
               let verseNumber = Int(String(cleaned[verseRange]).trimmingCharacters(in: .whitespaces)) {
                
                let startIndex = verseRange.upperBound
                let endIndex: String.Index
                if index < matches.count - 1,
                   let nextRange = Range(matches[index + 1].range, in: cleaned) {
                    endIndex = nextRange.lowerBound
                } else {
                    endIndex = cleaned.endIndex
                }
                
                let verseText = String(cleaned[startIndex..<endIndex])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !verseText.isEmpty {
                    verses.append((verseNumber: verseNumber, text: verseText))
                }
            }
        }
        
        // Fallback: if parsing fails, return entire content as verse 1
        if verses.isEmpty {
            let cleanedText = cleaned
                .replacingOccurrences(of: "&nbsp;", with: " ")
                .replacingOccurrences(of: "&amp;", with: "&")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !cleanedText.isEmpty {
                verses.append((verseNumber: 1, text: cleanedText))
            }
        }
        
        return verses
    }
}

// MARK: - Translation Picker View (Language-First Approach)
struct TranslationPickerView: View {
    let availableBibles: [BibleVersion]
    let currentBibleId: String
    let onSelect: (String, String) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var selectedLanguageId: String?
    @State private var showingTranslations = false

    // Get unique languages from available Bibles
    private var availableLanguages: [(id: String, name: String, count: Int)] {
        let grouped = Dictionary(grouping: availableBibles) { $0.language?.id ?? "unknown" }
        return grouped.map { (id: $0.key, name: grouped[$0.key]?.first?.language?.name ?? "Unknown", count: $0.value.count) }
            .sorted { $0.count > $1.count } // Sort by most translations
    }

    // Get current language
    private var currentLanguage: String {
        availableBibles.first(where: { $0.id == currentBibleId })?.language?.name ?? "English"
    }

    // Get current translation (without language prefix)
    private var currentTranslation: BibleVersion? {
        availableBibles.first(where: { $0.id == currentBibleId })
    }

    private var currentTranslationDisplay: String {
        if let translation = currentTranslation {
            return translation.abbreviation ?? translation.name
        }
        return "KJV"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if availableBibles.isEmpty {
                    VStack(spacing: AltarSpacing.large) {
                        BoldLoadingView()
                        Text("Loading translations...")
                            .foregroundColor(.white.opacity(0.6))
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: AltarSpacing.large) {
                            // Header
                            VStack(alignment: .leading, spacing: AltarSpacing.small) {
                                Text("Choose Translation")
                                    .font(.title.bold())
                                    .foregroundColor(.white)

                                Text("Currently reading: \(currentTranslationDisplay)")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.horizontal)
                            .padding(.top)

                            // Popular English Translations (Quick Access)
                            VStack(alignment: .leading, spacing: AltarSpacing.medium) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.altarYellow)
                                    Text("POPULAR")
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(.altarSoftGold)
                                }
                                .padding(.horizontal)

                                PopularTranslationsGrid(
                                    availableBibles: availableBibles,
                                    currentBibleId: currentBibleId,
                                    onSelect: onSelect
                                )
                            }

                            Divider()
                                .background(Color.white.opacity(0.2))
                                .padding(.horizontal)

                            // All Languages
                            VStack(alignment: .leading, spacing: AltarSpacing.medium) {
                                HStack {
                                    Image(systemName: "globe")
                                        .foregroundColor(.blue)
                                    Text("ALL LANGUAGES")
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(.altarSoftGold)
                                }
                                .padding(.horizontal)

                                ForEach(availableLanguages, id: \.id) { language in
                                    NavigationLink(destination:
                                        TranslationsListView(
                                            availableBibles: availableBibles.filter { $0.language?.id == language.id },
                                            languageName: language.name,
                                            currentBibleId: currentBibleId,
                                            onSelect: onSelect
                                        )
                                    ) {
                                        LanguageRow(
                                            languageName: language.name,
                                            translationCount: language.count,
                                            isCurrentLanguage: availableBibles.first(where: { $0.id == currentBibleId })?.language?.id == language.id
                                        )
                                    }
                                }
                            }

                            Spacer(minLength: 50)
                        }
                    }
                }
            }
            .navigationTitle("Bible Translation")
            .altarTitleInline()
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Popular Translations Grid
struct PopularTranslationsGrid: View {
    let availableBibles: [BibleVersion]
    let currentBibleId: String
    let onSelect: (String, String) -> Void

    private let popularAbbreviations = ["KJV", "NIV", "ESV", "NLT", "NKJV", "NASB"]

    private var popularBibles: [BibleVersion] {
        popularAbbreviations.compactMap { abbr in
            availableBibles.first { $0.abbreviation == abbr }
        }
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: AltarSpacing.medium) {
            ForEach(popularBibles) { bible in
                Button(action: {
                    onSelect(bible.id, bible.abbreviation ?? bible.name)
                    HapticManager.shared.trigger(.light)
                }) {
                    VStack(spacing: 8) {
                        Text(bible.abbreviation ?? "")
                            .font(.title2.bold())
                            .foregroundColor(bible.id == currentBibleId ? .black : .white)

                        if bible.id == currentBibleId {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.black)
                                .font(.caption)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        bible.id == currentBibleId
                            ? LinearGradient.altarMetallicGold
                            : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                    )
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(bible.id == currentBibleId ? Color.altarSoftGold : Color.white.opacity(0.2), lineWidth: bible.id == currentBibleId ? 2 : 1)
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Language Row
struct LanguageRow: View {
    let languageName: String
    let translationCount: Int
    let isCurrentLanguage: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(languageName)
                    .font(.headline)
                    .foregroundColor(.white)

                Text("\(translationCount) translation\(translationCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            if isCurrentLanguage {
                Text("Current")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.altarOrange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.altarOrange.opacity(0.2))
                    .cornerRadius(6)
            }

            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.3))
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Translations List View (for selected language)
struct TranslationsListView: View {
    let availableBibles: [BibleVersion]
    let languageName: String
    let currentBibleId: String
    let onSelect: (String, String) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    private var filteredBibles: [BibleVersion] {
        if searchText.isEmpty {
            return availableBibles.sorted { ($0.abbreviation ?? $0.name) < ($1.abbreviation ?? $1.name) }
        }
        return availableBibles.filter { bible in
            bible.name.localizedCaseInsensitiveContains(searchText) ||
            (bible.abbreviation?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.5))
                    TextField("Search \(languageName) translations...", text: $searchText)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding()

                // Translation list
                ScrollView {
                    VStack(spacing: AltarSpacing.small) {
                        ForEach(filteredBibles) { bible in
                            Button(action: {
                                onSelect(bible.id, bible.abbreviation ?? bible.name)
                                HapticManager.shared.trigger(.medium)
                                dismiss()
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            if let abbreviation = bible.abbreviation {
                                                Text(abbreviation)
                                                    .font(.headline.weight(.bold))
                                                    .foregroundColor(bible.id == currentBibleId ? .altarOrange : .white)
                                            }

                                            if bible.id == currentBibleId {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.altarOrange)
                                                    .font(.caption)
                                            }
                                        }

                                        Text(bible.name)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                .padding()
                                .background(
                                    bible.id == currentBibleId
                                        ? Color.altarOrange.opacity(0.15)
                                        : Color.white.opacity(0.06)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            bible.id == currentBibleId
                                                ? Color.altarSoftGold.opacity(0.5)
                                                : Color.white.opacity(0.1),
                                            lineWidth: bible.id == currentBibleId ? 2 : 1
                                        )
                                )
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Choose Translation")
        .altarTitleInline()
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .altarTrailing) {
                Button("Done") { dismiss() }
                    .foregroundColor(.altarSoftGold)
            }
        }
    }
}

// MARK: - Bold Book Picker View
struct BoldBookPickerView: View {
    let books: [BibleBook]
    let onSelect: (BibleBook) -> Void
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss

    private var oldTestamentBooks: [BibleBook] {
        let otNames = ["Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", "Ruth",
                       "1 Samuel", "2 Samuel", "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles",
                       "Ezra", "Nehemiah", "Esther", "Job", "Psalms", "Proverbs", "Ecclesiastes",
                       "Song of Solomon", "Isaiah", "Jeremiah", "Lamentations", "Ezekiel", "Daniel",
                       "Hosea", "Joel", "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk",
                       "Zephaniah", "Haggai", "Zechariah", "Malachi"]
        return books.filter { otNames.contains($0.name) }
    }

    private var newTestamentBooks: [BibleBook] {
        let otNames = Set(oldTestamentBooks.map { $0.id })
        return books.filter { !otNames.contains($0.id) }
    }

    private var filteredBooks: [BibleBook] {
        if searchText.isEmpty { return books }
        return books.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: AltarSpacing.large) {
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white.opacity(0.5))
                            TextField("Search books...", text: $searchText)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)

                        if searchText.isEmpty {
                            // Old Testament section
                            BookSection(title: "Old Testament", books: oldTestamentBooks, onSelect: onSelect)

                            // New Testament section
                            BookSection(title: "New Testament", books: newTestamentBooks, onSelect: onSelect)
                        } else {
                            // Filtered results
                            BookSection(title: "Results", books: filteredBooks, onSelect: onSelect)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Choose a Book")
            .altarTitleInline()
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .altarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.altarSoftGold)
                }
            }
        }
    }
}

// MARK: - Book Section
struct BookSection: View {
    let title: String
    let books: [BibleBook]
    let onSelect: (BibleBook) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AltarSpacing.medium) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundColor(.altarSoftGold)
                .padding(.horizontal)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AltarSpacing.small) {
                ForEach(books) { book in
                    Button(action: { onSelect(book) }) {
                        HStack {
                            Text(book.name)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding()
                        .background(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Legacy Chapter Content (compatibility)
struct ChapterContentView: View {
    let chapter: BibleChapterContent
    let onMarkComplete: () -> Void
    let onHighlight: (String, String) -> Void
    let onPrayLater: (String, String) -> Void

    var body: some View {
        BoldChapterContentView(
            chapter: chapter,
            bookName: "",
            currentChapterNumber: 1,
            maxChapterNumber: 50, // Default fallback for legacy compatibility
            translationName: BibleAPIManager.shared.currentBibleName,
            highlightedVerses: [],
            onMarkComplete: onMarkComplete,
            onPreviousChapter: {},
            onNextChapter: {},
            onHighlight: onHighlight,
            onPrayLater: onPrayLater
        )
    }
}

// MARK: - Legacy Book Picker (compatibility)
struct BookPickerView: View {
    let books: [BibleBook]
    let onSelect: (BibleBook) -> Void

    var body: some View {
        BoldBookPickerView(books: books, onSelect: onSelect)
    }
}

// MARK: - Add Verse Note View
struct AddVerseNoteView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.dismiss) var dismiss
    let verseId: String
    let verseText: String
    @State private var noteText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: AltarSpacing.large) {
                VStack(alignment: .leading, spacing: AltarSpacing.small) {
                    Text(verseId)
                        .font(.caption.weight(.bold))
                        .foregroundColor(.altarOrange)

                    Text(verseText)
                        .font(.body.italic())
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
                .background(Color.white.opacity(0.06))
                .cornerRadius(12)

                VStack(alignment: .leading, spacing: AltarSpacing.small) {
                    Text("Your Note")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.8))

                    TextEditor(text: $noteText)
                        .frame(minHeight: 200)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                }

                Spacer()
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Add Note")
            .altarTitleInline()
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dataStore.addNote(verseId: verseId, content: verseText, noteText: noteText)
                        HapticManager.shared.trigger(.medium)
                        dismiss()
                    }
                    .foregroundColor(.altarOrange)
                    .disabled(noteText.isEmpty)
                }
            }
        }
    }
}

// MARK: - Unified Verse Actions Sheet
struct UnifiedVerseActionsSheet: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.dismiss) var dismiss
    let verseId: String
    let verseText: String

    @State private var selectedColor: HighlightColor = .yellow
    @State private var showAddNote = false

    var existingHighlight: VerseAction? {
        dataStore.getHighlightForVerse(verseId: verseId)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AltarSpacing.large) {
                    // Verse Preview
                    VStack(alignment: .leading, spacing: AltarSpacing.small) {
                        Text(verseId)
                            .font(.caption.weight(.bold))
                            .foregroundColor(.altarOrange)

                        Text(verseText)
                            .font(.body.italic())
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)

                    // Color Picker Section
                    VStack(alignment: .leading, spacing: AltarSpacing.medium) {
                        HStack {
                            Image(systemName: "paintpalette.fill")
                                .foregroundColor(.altarOrange)
                            Text("HIGHLIGHT COLOR")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.white.opacity(0.7))
                        }

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                            ForEach(HighlightColor.allCases) { color in
                                Button(action: {
                                    selectedColor = color
                                    HapticManager.shared.trigger(.light)
                                }) {
                                    VStack(spacing: 6) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(color.color)
                                            .frame(height: 50)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedColor == color ? Color.white : Color.white.opacity(0.2), lineWidth: selectedColor == color ? 3 : 1)
                                            )

                                        if selectedColor == color {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.altarSuccess)
                                                .font(.caption)
                                        }

                                        Text(color.displayName)
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                            }
                        }
                    }

                    // Action Buttons Section
                    VStack(spacing: 12) {
                        // Highlight / Change Color Button
                        Button(action: {
                            if existingHighlight != nil {
                                dataStore.updateHighlightColor(verseId: verseId, color: selectedColor)
                            } else {
                                dataStore.addVerseAction(verseId: verseId, action: .highlight, content: verseText, highlightColor: selectedColor)
                            }
                            HapticManager.shared.trigger(.success)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: existingHighlight != nil ? "paintbrush.fill" : "highlighter")
                                Text(existingHighlight != nil ? "Change Highlight Color" : "Highlight Verse")
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

                        // Prayer Point Button (NEW)
                        Button(action: {
                            dataStore.addPrayerPointFromVerse(verseId: verseId, content: verseText)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "flame.fill")
                                Text("Add as Prayer Point")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.altarYellow.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.altarYellow, lineWidth: 2)
                            )
                            .cornerRadius(12)
                        }

                        // Pray Later Button
                        Button(action: {
                            dataStore.addVerseAction(verseId: verseId, action: .prayLater, content: verseText)
                            HapticManager.shared.trigger(.medium)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "bookmark.fill")
                                Text("Pray Later")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.altarOrange.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.altarOrange.opacity(0.5), lineWidth: 1.5)
                            )
                            .cornerRadius(12)
                        }

                        HStack(spacing: 12) {
                            // Add Note Button
                            Button(action: {
                                showAddNote = true
                            }) {
                                VStack(spacing: 6) {
                                    Image(systemName: "note.text")
                                        .font(.title3)
                                    Text("Note")
                                        .font(.caption.weight(.medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }

                            // Share Button
                            ShareLink(item: "\(verseText)\n\n- \(verseId)") {
                                VStack(spacing: 6) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.title3)
                                    Text("Share")
                                        .font(.caption.weight(.medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }

                            // Copy Button
                            Button(action: {
                                #if canImport(UIKit)
                                UIPasteboard.general.string = verseText
                                #endif
                                HapticManager.shared.trigger(.success)
                                dismiss()
                            }) {
                                VStack(spacing: 6) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.title3)
                                    Text("Copy")
                                        .font(.caption.weight(.medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }

                        // Remove Highlight Button (only if highlighted)
                        if existingHighlight != nil {
                            Button(role: .destructive, action: {
                                dataStore.removeVerseAction(verseId: verseId, action: .highlight)
                                HapticManager.shared.trigger(.light)
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Remove Highlight")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.red.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                )
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Verse Actions")
            .altarTitleInline()
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showAddNote) {
                AddVerseNoteView(verseId: verseId, verseText: verseText)
            }
            .onAppear {
                // Set initial color to existing highlight or default
                if let existing = existingHighlight {
                    selectedColor = existing.highlightColor ?? .yellow
                }
            }
        }
    }
}

// MARK: - Legacy Highlight Color Picker (for backward compatibility)
struct HighlightColorPicker: View {
    let verseId: String
    let verseText: String

    var body: some View {
        UnifiedVerseActionsSheet(verseId: verseId, verseText: verseText)
    }
}

// MARK: - Bible Search View
struct BibleSearchView: View {
    @StateObject private var bibleManager = BibleAPIManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var searchResults: [BibleSearchResult] = []
    @State private var isSearching = false
    @State private var searchError: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    HStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white.opacity(0.5))

                            TextField("Search the Bible...", text: $searchText)
                                .foregroundColor(.white)
                                .submitLabel(.search)
                                .onSubmit {
                                    performSearch()
                                }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)

                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                searchResults = []
                                searchError = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                    }
                    .padding()

                    // Results
                    if isSearching {
                        VStack(spacing: AltarSpacing.large) {
                            Spacer()
                            BoldLoadingView()
                            Text("Searching...")
                                .foregroundColor(.white.opacity(0.6))
                            Spacer()
                        }
                    } else if let error = searchError {
                        VStack(spacing: AltarSpacing.medium) {
                            Spacer()
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 48))
                                .foregroundColor(.altarRed)
                            Text("Search Error")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.white)
                            Text(error)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button("Try Again") {
                                performSearch()
                            }
                            .buttonStyle(AltarBoldButtonStyle())
                            .padding(.top)
                            Spacer()
                        }
                    } else if searchResults.isEmpty && !searchText.isEmpty {
                        VStack(spacing: AltarSpacing.medium) {
                            Spacer()
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 64))
                                .foregroundColor(.white.opacity(0.3))
                            Text("No Results")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.white)
                            Text("Try a different search term")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.6))
                            Spacer()
                        }
                    } else if searchResults.isEmpty {
                        VStack(spacing: AltarSpacing.medium) {
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 64))
                                .foregroundColor(.altarOrange.opacity(0.5))
                            Text("Search the Bible")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.white)
                            Text("Find verses by keyword or phrase")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.6))
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: AltarSpacing.small) {
                                HStack {
                                    Text("\(searchResults.count) result\(searchResults.count == 1 ? "" : "s")")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.5))
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)

                                ForEach(searchResults) { result in
                                    SearchResultCard(result: result)
                                }
                            }
                            .padding(.bottom)
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .altarTitleInline()
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }

    private func performSearch() {
        guard !searchText.isEmpty else { return }
        isSearching = true
        searchError = nil

        bibleManager.searchBible(query: searchText) { result in
            isSearching = false
            switch result {
            case .success(let results):
                searchResults = results
            case .failure(let error):
                searchError = error.localizedDescription
            }
        }
    }
}

// MARK: - Search Result Card
struct SearchResultCard: View {
    @EnvironmentObject var dataStore: AppDataStore
    let result: BibleSearchResult
    @State private var showVerseActions = false

    var body: some View {
        VStack(alignment: .leading, spacing: AltarSpacing.small) {
            HStack {
                Text(result.displayReference)
                    .font(.caption.weight(.bold))
                    .foregroundColor(.altarOrange)
                Spacer()
            }

            Text(cleanHTMLText(result.text))
                .font(.system(size: 16, design: .serif))
                .lineSpacing(6)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .cornerRadius(12)
        .padding(.horizontal)
        .onTapGesture {
            showVerseActions = true
        }
        .confirmationDialog("Verse Actions", isPresented: $showVerseActions) {
            Button("Highlight") {
                dataStore.addVerseAction(verseId: result.id, action: .highlight, content: cleanHTMLText(result.text), highlightColor: .yellow)
                HapticManager.shared.trigger(.medium)
            }

            Button("Add Note") {
                // Would need to present note view
            }

            Button("Pray Later") {
                dataStore.addVerseAction(verseId: result.id, action: .prayLater, content: cleanHTMLText(result.text))
                HapticManager.shared.trigger(.medium)
            }

            ShareLink(item: "\(cleanHTMLText(result.text)) - \(result.displayReference)") {
                Text("Share")
            }

            Button("Cancel", role: .cancel) {}
        }
    }

    private func cleanHTMLText(_ html: String) -> String {
        html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Verse Picker Sheet
struct VersePickerSheet: View {
    let parsedVerses: [(verseNumber: Int, text: String)]
    let currentVerse: Int?
    let onSelectVerse: (Int) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    private var filteredVerses: [(verseNumber: Int, text: String)] {
        if searchText.isEmpty {
            return parsedVerses
        } else if let verseNumber = Int(searchText) {
            return parsedVerses.filter { $0.verseNumber == verseNumber }
        } else {
            return parsedVerses
        }
    }

    private func verseBackground(for verseNumber: Int) -> AnyView {
        if currentVerse == verseNumber {
            return AnyView(
                LinearGradient(
                    colors: [.altarGradientStart, .altarGradientEnd],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        } else {
            return AnyView(Color.white.opacity(0.08))
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.5))
                        TextField("Verse number...", text: $searchText)
                            .keyboardType(.numberPad)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .padding()

                    // Verse list
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredVerses, id: \.verseNumber) { verse in
                                Button(action: {
                                    onSelectVerse(verse.verseNumber)
                                    HapticManager.shared.trigger(.light)
                                    dismiss()
                                }) {
                                    HStack(alignment: .top, spacing: 12) {
                                        Text("\(verse.verseNumber)")
                                            .font(.headline.bold())
                                            .foregroundColor(currentVerse == verse.verseNumber ? .black : .altarOrange)
                                            .frame(width: 40)

                                        Text(verse.text)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)

                                        Spacer()
                                    }
                                    .padding()
                                    .background(verseBackground(for: verse.verseNumber))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Jump to Verse")
            .altarTitleInline()
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.altarOrange)
                }
            }
        }
    }
}

// MARK: - Continuous Scroll Bible View
struct ContinuousScrollBibleView: View {
    let currentBook: BibleBook
    @Binding var currentChapterNumber: Int
    @Binding var loadedChapters: [Int: BibleChapterContent]
    let maxChapterNumber: Int
    let translationName: String
    let highlightedVerses: Set<String>
    let onMarkComplete: (Int) -> Void
    let onHighlight: (String, String) -> Void
    let onLoadChapter: (Int) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                // Previous chapter
                if currentChapterNumber > 1, let prevChapter = loadedChapters[currentChapterNumber - 1] {
                    ChapterSection(
                        chapter: prevChapter,
                        chapterNumber: currentChapterNumber - 1,
                        translationName: translationName,
                        highlightedVerses: highlightedVerses,
                        onMarkComplete: { onMarkComplete(currentChapterNumber - 1) },
                        onHighlight: onHighlight
                    )
                    .id("chapter-\(currentChapterNumber - 1)")
                }

                // Current chapter
                if let chapter = loadedChapters[currentChapterNumber] {
                    ChapterSection(
                        chapter: chapter,
                        chapterNumber: currentChapterNumber,
                        translationName: translationName,
                        highlightedVerses: highlightedVerses,
                        onMarkComplete: { onMarkComplete(currentChapterNumber) },
                        onHighlight: onHighlight
                    )
                    .id("chapter-\(currentChapterNumber)")
                    .onAppear { preloadAdjacentChapters() }
                }

                // Next chapter
                if currentChapterNumber < maxChapterNumber {
                    if let nextChapter = loadedChapters[currentChapterNumber + 1] {
                        ChapterSection(
                            chapter: nextChapter,
                            chapterNumber: currentChapterNumber + 1,
                            translationName: translationName,
                            highlightedVerses: highlightedVerses,
                            onMarkComplete: { onMarkComplete(currentChapterNumber + 1) },
                            onHighlight: onHighlight
                        )
                        .id("chapter-\(currentChapterNumber + 1)")
                    } else {
                        // Load more button
                        Button(action: {
                            onLoadChapter(currentChapterNumber + 1)
                        }) {
                            HStack {
                                Image(systemName: "arrow.down.circle")
                                Text("Load Next Chapter")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(.top)
        }
    }

    private func preloadAdjacentChapters() {
        if currentChapterNumber > 1 && loadedChapters[currentChapterNumber - 1] == nil {
            onLoadChapter(currentChapterNumber - 1)
        }
        if currentChapterNumber < maxChapterNumber && loadedChapters[currentChapterNumber + 1] == nil {
            onLoadChapter(currentChapterNumber + 1)
        }
    }
}

// MARK: - Chapter Section for Continuous Scroll
struct ChapterSection: View {
    @EnvironmentObject var dataStore: AppDataStore
    let chapter: BibleChapterContent
    let chapterNumber: Int
    let translationName: String
    let highlightedVerses: Set<String>
    let onMarkComplete: () -> Void
    let onHighlight: (String, String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Chapter header with fire gradient divider
            VStack(spacing: 8) {
                Text(chapter.reference)
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.altarRed, .altarOrange, .altarYellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 2)
                    .shadow(color: .altarOrange.opacity(0.6), radius: 8)
            }
            .padding(.horizontal)

            // Verses
            VerseContentView(
                content: chapter.content,
                bookId: chapter.id.components(separatedBy: ".").first ?? "",
                chapterNumber: chapterNumber,
                highlightedVerses: highlightedVerses,
                onVerseTap: onHighlight
            )
            .padding(.horizontal)

            // Mark complete button
            Button(action: onMarkComplete) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Mark Chapter \(chapterNumber) Complete")
                }
                .font(.headline.weight(.semibold))
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
                .cornerRadius(16)
                .shadow(color: .altarSoftGold.opacity(0.3), radius: 10, x: 0, y: 4)
            }
            .padding(.horizontal)
        }
    }
}
