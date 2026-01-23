import Foundation

/// Service for fetching and caching content from the remote JSON file
@MainActor
class ContentService: ObservableObject {

    // MARK: - Published Properties
    @Published var sites: [Site] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var lastUpdated: Date?

    // MARK: - Configuration

    /// GitHub raw URL for the content JSON
    private let remoteURL = "https://raw.githubusercontent.com/Naareman/UnlockEgypt/main/content/unlock_egypt_content.json"

    /// Local cache file name
    private let cacheFileName = "unlock_egypt_content_cache.json"

    /// Bundled JSON file name (included in app bundle)
    private let bundledFileName = "unlock_egypt_content"

    // MARK: - Singleton
    static let shared = ContentService()

    private init() {
        // Load content: cache first, then bundled fallback
        loadInitialContent()
    }

    // MARK: - Public Methods

    /// Fetch fresh content from remote, falling back to cache/bundled
    func fetchContent() async {
        isLoading = true
        error = nil

        do {
            // Try to fetch from remote
            let remoteContent = try await fetchRemoteContent()
            self.sites = remoteContent.sites
            self.lastUpdated = ISO8601DateFormatter().date(from: remoteContent.lastUpdated)

            // Cache the fresh content
            saveToCache(remoteContent)

            print("ContentService: Loaded \(sites.count) sites from remote")
        } catch {
            print("ContentService: Remote fetch failed: \(error.localizedDescription)")

            // Keep using current content (cache or bundled)
            if sites.isEmpty {
                loadInitialContent()
            }

            self.error = error.localizedDescription
        }

        isLoading = false
    }

    /// Force refresh from remote
    func refresh() async {
        await fetchContent()
    }

    // MARK: - Private Methods

    private func fetchRemoteContent() async throws -> ContentResponse {
        guard let url = URL(string: remoteURL) else {
            throw ContentError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ContentError.serverError
        }

        let decoder = JSONDecoder()
        return try decoder.decode(ContentResponse.self, from: data)
    }

    /// Load content from cache, falling back to bundled JSON
    private func loadInitialContent() {
        // Try cache first
        if loadCachedContent() {
            return
        }

        // Fall back to bundled JSON
        loadBundledContent()
    }

    /// Load from cache, returns true if successful
    private func loadCachedContent() -> Bool {
        guard let cacheURL = cacheFileURL,
              FileManager.default.fileExists(atPath: cacheURL.path) else {
            return false
        }

        do {
            let data = try Data(contentsOf: cacheURL)
            let decoder = JSONDecoder()
            let content = try decoder.decode(ContentResponse.self, from: data)
            self.sites = content.sites
            self.lastUpdated = ISO8601DateFormatter().date(from: content.lastUpdated)
            print("ContentService: Loaded \(sites.count) sites from cache")
            return true
        } catch {
            print("ContentService: Cache load failed: \(error.localizedDescription)")
            return false
        }
    }

    /// Load from bundled JSON file in app bundle
    private func loadBundledContent() {
        guard let bundledURL = Bundle.main.url(forResource: bundledFileName, withExtension: "json") else {
            print("ContentService: Bundled JSON not found")
            return
        }

        do {
            let data = try Data(contentsOf: bundledURL)
            let decoder = JSONDecoder()
            let content = try decoder.decode(ContentResponse.self, from: data)
            self.sites = content.sites
            self.lastUpdated = ISO8601DateFormatter().date(from: content.lastUpdated)
            print("ContentService: Loaded \(sites.count) sites from bundled JSON")
        } catch {
            print("ContentService: Bundled JSON load failed: \(error.localizedDescription)")
        }
    }

    private func saveToCache(_ content: ContentResponse) {
        guard let cacheURL = cacheFileURL else { return }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(content)
            try data.write(to: cacheURL)
            print("ContentService: Saved to cache")
        } catch {
            print("ContentService: Cache save failed: \(error.localizedDescription)")
        }
    }

    private var cacheFileURL: URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent(cacheFileName)
    }
}

// MARK: - Content Response Model
struct ContentResponse: Codable {
    let version: String
    let lastUpdated: String
    let sites: [Site]
}

// MARK: - Content Errors
enum ContentError: LocalizedError {
    case invalidURL
    case serverError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid content URL"
        case .serverError:
            return "Server error"
        }
    }
}
