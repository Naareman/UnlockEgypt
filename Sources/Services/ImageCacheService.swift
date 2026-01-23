import SwiftUI
import UIKit
import Combine

/// Manages image caching for offline support
@MainActor
class ImageCacheService: ObservableObject {
    static let shared = ImageCacheService()

    @Published var downloadProgress: Double = 0
    @Published var isDownloading: Bool = false
    @Published var totalImages: Int = 0
    @Published var downloadedImages: Int = 0
    @Published var lastCacheUpdate: Date?
    @Published var cacheSize: Int64 = 0
    @Published var lastDownloadResult: String?

    private let cacheDirectory: URL
    private let metadataFile: URL

    /// Maximum cache size in bytes (100 MB)
    private let maxCacheSize: Int64 = 100 * 1024 * 1024

    /// Cache expiration time (30 days)
    private let cacheExpirationDays: Double = 30

    private init() {
        // Safe unwrap with fallback to temporary directory
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        cacheDirectory = cachesDir.appendingPathComponent("ImageCache", isDirectory: true)
        metadataFile = cachesDir.appendingPathComponent("image_cache_metadata.json")

        // Create cache directory if needed
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        loadMetadata()
        calculateCacheSize()

        // Clean expired cache on launch
        Task {
            await cleanExpiredCache()
        }
    }

    // MARK: - Cache Size Management

    /// Clean up cache if it exceeds maximum size
    private func enforceCacheSizeLimit() async {
        guard cacheSize > maxCacheSize else { return }

        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async { [weak self] in
                guard let self = self else {
                    continuation.resume()
                    return
                }

                // Get all cached files with their dates
                var files: [(url: URL, date: Date, size: Int64)] = []

                if let enumerator = FileManager.default.enumerator(
                    at: self.cacheDirectory,
                    includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey]
                ) {
                    for case let fileURL as URL in enumerator {
                        if let values = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
                           let date = values.contentModificationDate,
                           let size = values.fileSize {
                            files.append((fileURL, date, Int64(size)))
                        }
                    }
                }

                // Sort by date (oldest first)
                files.sort { $0.date < $1.date }

                // Remove oldest files until under limit
                var currentSize = self.cacheSize
                let targetSize = self.maxCacheSize * 80 / 100 // Target 80% of max

                for file in files {
                    guard currentSize > targetSize else { break }
                    try? FileManager.default.removeItem(at: file.url)
                    currentSize -= file.size
                }

                DispatchQueue.main.async {
                    self.calculateCacheSize()
                    continuation.resume()
                }
            }
        }
    }

    /// Clean cache entries older than expiration time
    private func cleanExpiredCache() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async { [weak self] in
                guard let self = self else {
                    continuation.resume()
                    return
                }

                let expirationDate = Date().addingTimeInterval(-self.cacheExpirationDays * 24 * 60 * 60)

                if let enumerator = FileManager.default.enumerator(
                    at: self.cacheDirectory,
                    includingPropertiesForKeys: [.contentModificationDateKey]
                ) {
                    for case let fileURL as URL in enumerator {
                        if let values = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]),
                           let date = values.contentModificationDate,
                           date < expirationDate {
                            try? FileManager.default.removeItem(at: fileURL)
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.calculateCacheSize()
                    continuation.resume()
                }
            }
        }
    }

    // MARK: - Metadata Management

    private struct CacheMetadata: Codable {
        var lastUpdate: Date?
        var cachedURLs: [String]
    }

    private func loadMetadata() {
        guard let data = try? Data(contentsOf: metadataFile),
              let metadata = try? JSONDecoder().decode(CacheMetadata.self, from: data) else {
            return
        }
        lastCacheUpdate = metadata.lastUpdate
    }

    private func saveMetadata(urls: [String]) {
        let metadata = CacheMetadata(lastUpdate: Date(), cachedURLs: urls)
        if let data = try? JSONEncoder().encode(metadata) {
            try? data.write(to: metadataFile)
        }
        lastCacheUpdate = metadata.lastUpdate
    }

    // MARK: - Cache Size

    func calculateCacheSize() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }

            var totalSize: Int64 = 0
            if let enumerator = FileManager.default.enumerator(at: self.cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
                for case let fileURL as URL in enumerator {
                    if let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                       let fileSize = resourceValues.fileSize {
                        totalSize += Int64(fileSize)
                    }
                }
            }

            DispatchQueue.main.async {
                self.cacheSize = totalSize
            }
        }
    }

    var formattedCacheSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: cacheSize)
    }

    // MARK: - Image Loading

    /// Maximum retry attempts for failed downloads
    private let maxRetries = 3

    /// Delay between retries in seconds
    private let retryDelay: UInt64 = 1_000_000_000 // 1 second

    /// Get cached image or download it with retry logic
    func getImage(from urlString: String, retryCount: Int = 0) async -> UIImage? {
        guard !urlString.isEmpty else { return nil }

        // Validate and force HTTPS
        var secureURLString = urlString
        if urlString.hasPrefix("http://") {
            secureURLString = urlString.replacingOccurrences(of: "http://", with: "https://")
        }

        guard let url = URL(string: secureURLString) else { return nil }

        let fileName = urlString.hash.description
        let localURL = cacheDirectory.appendingPathComponent(fileName)

        // Check cache first
        if FileManager.default.fileExists(atPath: localURL.path),
           let data = try? Data(contentsOf: localURL),
           let image = UIImage(data: data) {
            return image
        }

        // Download if not cached with retry logic
        do {
            // Configure request with timeout
            var request = URLRequest(url: url)
            request.timeoutInterval = 30

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return await retryIfNeeded(urlString: urlString, retryCount: retryCount, error: "Invalid response")
            }

            // Handle HTTP errors
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode >= 500 && retryCount < maxRetries {
                    // Server error - retry
                    return await retryIfNeeded(urlString: urlString, retryCount: retryCount, error: "Server error: \(httpResponse.statusCode)")
                }
                return nil
            }

            guard let image = UIImage(data: data) else {
                // Invalid image data - don't retry
                return nil
            }

            // Cache the image
            try? data.write(to: localURL)
            calculateCacheSize()

            // Enforce cache size limit in background
            Task {
                await enforceCacheSizeLimit()
            }

            return image
        } catch let error as URLError {
            // Network errors that are worth retrying
            let retryableErrors: [URLError.Code] = [.timedOut, .networkConnectionLost, .notConnectedToInternet]
            if retryableErrors.contains(error.code) && retryCount < maxRetries {
                return await retryIfNeeded(urlString: urlString, retryCount: retryCount, error: error.localizedDescription)
            }
            return nil
        } catch {
            return await retryIfNeeded(urlString: urlString, retryCount: retryCount, error: error.localizedDescription)
        }
    }

    /// Retry helper with exponential backoff
    private func retryIfNeeded(urlString: String, retryCount: Int, error: String) async -> UIImage? {
        guard retryCount < maxRetries else { return nil }

        // Exponential backoff: 1s, 2s, 4s
        let delay = retryDelay * UInt64(1 << retryCount)
        try? await Task.sleep(nanoseconds: delay)

        return await getImage(from: urlString, retryCount: retryCount + 1)
    }

    // MARK: - Batch Download for Offline

    /// Check if an image is already cached
    private func isImageCached(_ urlString: String) -> Bool {
        guard !urlString.isEmpty else { return true }
        let fileName = urlString.hash.description
        let localURL = cacheDirectory.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: localURL.path)
    }

    /// Download all images from sites for offline use
    func downloadAllImages(from sites: [Site]) async {
        var allURLs: [String] = []

        // Collect all image URLs
        for site in sites {
            allURLs.append(contentsOf: site.imageNames.filter { !$0.isEmpty && $0.hasPrefix("http") })

            if let subLocations = site.subLocations {
                for sub in subLocations {
                    if let imageName = sub.imageName, !imageName.isEmpty, imageName.hasPrefix("http") {
                        allURLs.append(imageName)
                    }
                    for card in sub.storyCards {
                        if let imageName = card.imageName, !imageName.isEmpty, imageName.hasPrefix("http") {
                            allURLs.append(imageName)
                        }
                    }
                }
            }
        }

        // Remove duplicates
        allURLs = Array(Set(allURLs))

        // Check how many images need to be downloaded
        let uncachedURLs = allURLs.filter { !isImageCached($0) }

        // If no images to download (either no URLs or all cached), show checking animation
        if allURLs.isEmpty || uncachedURLs.isEmpty {
            // Show checking animation to give user feedback
            isDownloading = true
            downloadProgress = 0
            totalImages = 0
            lastDownloadResult = nil  // Hide previous message during check

            // Animate progress to make it feel like checking
            for i in 1...10 {
                try? await Task.sleep(nanoseconds: 150_000_000) // 150ms per step = 1.5s total
                downloadProgress = Double(i) / 10.0
            }

            isDownloading = false
            lastDownloadResult = "All content is up to date! ✓"
            lastCacheUpdate = Date()
            return
        }

        await MainActor.run {
            totalImages = uncachedURLs.count
            downloadedImages = 0
            downloadProgress = 0
            isDownloading = true
            lastDownloadResult = nil
        }

        // Download only uncached images
        for (index, urlString) in uncachedURLs.enumerated() {
            _ = await getImage(from: urlString)

            await MainActor.run {
                downloadedImages = index + 1
                downloadProgress = Double(downloadedImages) / Double(totalImages)
            }
        }

        await MainActor.run {
            isDownloading = false
            saveMetadata(urls: allURLs)
            calculateCacheSize()
            lastDownloadResult = "Downloaded \(downloadedImages) new images for offline use"
        }
    }

    // MARK: - Clear Cache

    func clearCache() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        try? FileManager.default.removeItem(at: metadataFile)

        lastCacheUpdate = nil
        lastDownloadResult = nil
        cacheSize = 0
    }

    // MARK: - Check for Updates

    /// Check if content has been updated since last cache
    func hasUpdatesAvailable(lastContentUpdate: Date?) -> Bool {
        guard let contentUpdate = lastContentUpdate,
              let cacheUpdate = lastCacheUpdate else {
            return true // If we don't know, assume updates available
        }
        return contentUpdate > cacheUpdate
    }
}

// MARK: - Cached Async Image View
struct CachedAsyncImage: View {
    let urlString: String?
    var placeholder: AnyView = AnyView(
        ZStack {
            Theme.Colors.cardBackground
            ProgressView()
                .tint(Theme.Colors.gold)
        }
    )

    @State private var image: UIImage?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                placeholder
            } else {
                // Failed to load - show placeholder
                ZStack {
                    Theme.Colors.cardBackground
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.3))
                }
            }
        }
        .task {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let urlString = urlString, !urlString.isEmpty else {
            isLoading = false
            return
        }

        image = await ImageCacheService.shared.getImage(from: urlString)
        isLoading = false
    }
}
