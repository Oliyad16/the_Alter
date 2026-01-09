import Foundation

class BibleAPIManager: ObservableObject {
    static let shared = BibleAPIManager()

    private let baseURL = "https://rest.api.bible/v1"
    
    // API Key Configuration:
    // Configured via environment variable, Info.plist, or fallback to hardcoded value
    private var apiKey: String {
        // First, try to get from environment variable (useful for CI/CD)
        if let envKey = ProcessInfo.processInfo.environment["BIBLE_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        
        // Then try to get from Info.plist
        if let infoKey = Bundle.main.object(forInfoDictionaryKey: "BibleAPIKey") as? String, !infoKey.isEmpty {
            return infoKey
        }
        
        // Fallback to configured API key
        return "dI4FM0Jkmd_h7ZqQGglbZ"
    }

    var currentBibleId: String {
        UserDefaults.standard.string(forKey: "selectedBibleId") ?? "de4e12af7f28f599-02"
    }
    
    var currentBibleName: String {
        UserDefaults.standard.string(forKey: "selectedBibleName") ?? "KJV"
    }

    @Published var isLoading = false
    @Published var error: String?
    @Published var availableBibles: [BibleVersion] = []

    // Dynamic property for popular translations (no duplicates)
    var popularTranslations: [BibleVersion] {
        let popularAbbrs = ["KJV", "NIV", "ESV", "NASB", "NLT", "NKJV"]
        return popularAbbrs.compactMap { abbr in
            availableBibles.first { $0.abbreviation == abbr }
        }
    }

    private init() {
        loadAvailableBibles()
    }
    
    // MARK: - Fetch Available Bible Versions
    func loadAvailableBibles() {
        let urlString = "\(baseURL)/bibles"
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "api-key")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let data = data,
                      let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else { return }
                
                do {
                    struct BibleVersionsResponse: Codable {
                        let data: [BibleVersion]
                    }
                    let response = try JSONDecoder().decode(BibleVersionsResponse.self, from: data)
                    self?.availableBibles = response.data
                } catch {
                    print("Failed to load Bible versions: \(error)")
                }
            }
        }.resume()
    }
    
    func setBibleVersion(_ bibleId: String, name: String) {
        UserDefaults.standard.set(bibleId, forKey: "selectedBibleId")
        UserDefaults.standard.set(name, forKey: "selectedBibleName")
    }

    // MARK: - Fetch Books
    func fetchBooks(completion: @escaping (Result<[BibleBook], Error>) -> Void) {
        let urlString = "\(baseURL)/bibles/\(currentBibleId)/books"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "api-key")

        isLoading = true

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    let errorMessage = "Network error: \(error.localizedDescription)"
                    self?.error = errorMessage
                    completion(.failure(error))
                    return
                }

                // Check HTTP response status
                if let httpResponse = response as? HTTPURLResponse {
                    guard (200...299).contains(httpResponse.statusCode) else {
                        let errorMessage = httpResponse.statusCode == 401 
                            ? "Invalid API key. Please get a free API key from https://scripture.api.bible/ and update BibleAPIManager.swift"
                            : "Server error: \(httpResponse.statusCode)"
                        let nsError = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        self?.error = errorMessage
                        completion(.failure(nsError))
                        return
                    }
                }

                guard let data = data else {
                    let error = NSError(domain: "No data", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])
                    self?.error = "No data received from server"
                    completion(.failure(error))
                    return
                }

                do {
                    let response = try JSONDecoder().decode(BibleBooksResponse.self, from: data)
                    self?.error = nil // Clear any previous errors
                    completion(.success(response.data))
                } catch {
                    let errorMessage = "Failed to parse response: \(error.localizedDescription)"
                    self?.error = errorMessage
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Fetch Chapter Content
    func fetchChapter(chapterId: String, completion: @escaping (Result<BibleChapterContent, Error>) -> Void) {
        // Try to load from cache first
        if let cachedChapter = getCachedChapter(chapterId: chapterId) {
            completion(.success(cachedChapter))
            // Still fetch in background to update cache
            fetchAndCacheChapter(chapterId: chapterId, completion: { _ in })
            return
        }

        fetchAndCacheChapter(chapterId: chapterId, completion: completion)
    }

    private func fetchAndCacheChapter(chapterId: String, completion: @escaping (Result<BibleChapterContent, Error>) -> Void) {
        let urlString = "\(baseURL)/bibles/\(currentBibleId)/chapters/\(chapterId)?content-type=text&include-verse-numbers=true"

        guard let url = URL(string: urlString) else {
            // Try cached version if URL fails
            if let cachedChapter = getCachedChapter(chapterId: chapterId) {
                completion(.success(cachedChapter))
            } else {
                completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            }
            return
        }

        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "api-key")

        isLoading = true

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    // If network fails, try to return cached version
                    if let cachedChapter = self?.getCachedChapter(chapterId: chapterId) {
                        completion(.success(cachedChapter))
                        return
                    }
                    let errorMessage = "Network error: \(error.localizedDescription)"
                    self?.error = errorMessage
                    completion(.failure(error))
                    return
                }

                // Check HTTP response status
                if let httpResponse = response as? HTTPURLResponse {
                    guard (200...299).contains(httpResponse.statusCode) else {
                        // If HTTP error, try to return cached version
                        if let cachedChapter = self?.getCachedChapter(chapterId: chapterId) {
                            completion(.success(cachedChapter))
                            return
                        }
                        let errorMessage: String
                        switch httpResponse.statusCode {
                        case 404:
                            errorMessage = "Chapter not found. Please check the chapter number."
                        case 401:
                            errorMessage = "Invalid API key. Please get a free API key from https://scripture.api.bible/ and update BibleAPIManager.swift"
                        default:
                            errorMessage = "Server error: \(httpResponse.statusCode)"
                        }
                        let nsError = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        self?.error = errorMessage
                        completion(.failure(nsError))
                        return
                    }
                }

                guard let data = data else {
                    // If no data, try to return cached version
                    if let cachedChapter = self?.getCachedChapter(chapterId: chapterId) {
                        completion(.success(cachedChapter))
                        return
                    }
                    let error = NSError(domain: "No data", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])
                    self?.error = "No data received from server"
                    completion(.failure(error))
                    return
                }

                do {
                    let response = try JSONDecoder().decode(BibleAPIResponse<BibleChapterContent>.self, from: data)
                    // Cache the chapter for offline access
                    self?.cacheChapter(response.data)
                    self?.error = nil // Clear any previous errors
                    completion(.success(response.data))
                } catch {
                    // If parsing fails, try to return cached version
                    if let cachedChapter = self?.getCachedChapter(chapterId: chapterId) {
                        completion(.success(cachedChapter))
                        return
                    }
                    let errorMessage = "Failed to parse chapter: \(error.localizedDescription)"
                    self?.error = errorMessage
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Cache Chapter Offline
    func cacheChapter(_ chapter: BibleChapterContent) {
        let key = "cached_chapter_\(chapter.id)"
        if let encoded = try? JSONEncoder().encode(chapter) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func getCachedChapter(chapterId: String) -> BibleChapterContent? {
        let key = "cached_chapter_\(chapterId)"
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(BibleChapterContent.self, from: data)
    }

    // MARK: - Search
    func searchBible(query: String, completion: @escaping (Result<[BibleSearchResult], Error>) -> Void) {
        guard !query.isEmpty else {
            completion(.success([]))
            return
        }

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/bibles/\(currentBibleId)/search?query=\(encodedQuery)&limit=50"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "api-key")

        isLoading = true

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 0)))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: 0)))
                    return
                }

                do {
                    let searchResponse = try JSONDecoder().decode(BibleSearchResponse.self, from: data)
                    completion(.success(searchResponse.data.verses))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

// MARK: - Search Models
struct BibleSearchResponse: Codable {
    let data: BibleSearchData
}

struct BibleSearchData: Codable {
    let verses: [BibleSearchResult]
}

struct BibleSearchResult: Codable, Identifiable {
    let id: String
    let orgId: String?
    let bookId: String
    let chapterId: String
    let text: String
    let reference: String

    var displayReference: String {
        reference
    }
}
