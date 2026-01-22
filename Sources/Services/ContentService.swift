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
    /// Format: https://raw.githubusercontent.com/{username}/{repo}/{branch}/content/unlock_egypt_content.json
    private let remoteURL = "https://raw.githubusercontent.com/Naareman/UnlockEgypt/main/content/unlock_egypt_content.json"

    /// Local cache file name
    private let cacheFileName = "unlock_egypt_content_cache.json"

    // MARK: - Singleton
    static let shared = ContentService()

    private init() {
        // Load cached content immediately
        loadCachedContent()
    }

    // MARK: - Public Methods

    /// Fetch fresh content from remote, falling back to cache
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

            // Fall back to cached content if available
            if sites.isEmpty {
                loadCachedContent()
            }

            // Fall back to sample data if still empty
            if sites.isEmpty {
                print("ContentService: Using sample data as fallback")
                sites = SampleData.sites
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

    private func loadCachedContent() {
        guard let cacheURL = cacheFileURL,
              FileManager.default.fileExists(atPath: cacheURL.path) else {
            // No cache, use sample data
            sites = SampleData.sites
            print("ContentService: No cache found, using sample data")
            return
        }

        do {
            let data = try Data(contentsOf: cacheURL)
            let decoder = JSONDecoder()
            let content = try decoder.decode(ContentResponse.self, from: data)
            self.sites = content.sites
            self.lastUpdated = ISO8601DateFormatter().date(from: content.lastUpdated)
            print("ContentService: Loaded \(sites.count) sites from cache")
        } catch {
            print("ContentService: Cache load failed: \(error.localizedDescription)")
            sites = SampleData.sites
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
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid content URL"
        case .serverError:
            return "Server error"
        case .decodingError:
            return "Failed to parse content"
        }
    }
}
