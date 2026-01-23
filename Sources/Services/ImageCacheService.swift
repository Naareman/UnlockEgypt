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

    private let cacheDirectory: URL
    private let metadataFile: URL

    private init() {
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDir.appendingPathComponent("ImageCache", isDirectory: true)
        metadataFile = cachesDir.appendingPathComponent("image_cache_metadata.json")

        // Create cache directory if needed
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        loadMetadata()
        calculateCacheSize()
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

    /// Get cached image or download it
    func getImage(from urlString: String) async -> UIImage? {
        guard !urlString.isEmpty, let url = URL(string: urlString) else { return nil }

        let fileName = urlString.hash.description
        let localURL = cacheDirectory.appendingPathComponent(fileName)

        // Check cache first
        if FileManager.default.fileExists(atPath: localURL.path),
           let data = try? Data(contentsOf: localURL),
           let image = UIImage(data: data) {
            return image
        }

        // Download if not cached
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let image = UIImage(data: data) else {
                return nil
            }

            // Cache the image
            try? data.write(to: localURL)
            calculateCacheSize()

            return image
        } catch {
            print("ImageCacheService: Failed to download image from \(urlString): \(error)")
            return nil
        }
    }

    // MARK: - Batch Download for Offline

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

        guard !allURLs.isEmpty else {
            print("ImageCacheService: No images to download")
            return
        }

        await MainActor.run {
            totalImages = allURLs.count
            downloadedImages = 0
            downloadProgress = 0
            isDownloading = true
        }

        // Download each image
        for (index, urlString) in allURLs.enumerated() {
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
        }

        print("ImageCacheService: Downloaded \(allURLs.count) images for offline use")
    }

    // MARK: - Clear Cache

    func clearCache() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        try? FileManager.default.removeItem(at: metadataFile)

        lastCacheUpdate = nil
        cacheSize = 0
        print("ImageCacheService: Cache cleared")
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
