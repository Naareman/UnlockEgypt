import Foundation
import CoreLocation
import UIKit
import Combine

// MARK: - Content Service Protocol

/// Protocol for content/site data management
@MainActor
protocol ContentServiceProtocol: ObservableObject {
    /// All available sites
    var sites: [Site] { get }

    /// Loading state
    var isLoading: Bool { get }

    /// Publisher for sites updates
    var sitesPublisher: AnyPublisher<[Site], Never> { get }

    /// Refresh content from remote or cache
    func refresh() async
}

// MARK: - Location Service Protocol

/// Protocol for location services
@MainActor
protocol LocationServiceProtocol: ObservableObject {
    /// Current user location
    var location: CLLocation? { get }

    /// Current authorization status
    var authorizationStatus: CLAuthorizationStatus { get }

    /// Human-readable location name
    var locationName: String { get }

    /// Last error message
    var locationError: String? { get }

    /// Whether a location request is in progress
    var isRequestingLocation: Bool { get }

    /// Check if location services are authorized
    var isAuthorized: Bool { get }

    /// Check if location services are denied
    var isDenied: Bool { get }

    /// Request location permission
    func requestPermission()

    /// Request a single location update
    func requestLocation()

    /// Request location with callback
    func requestLocationWithCallback(completion: @escaping (CLLocation?) -> Void)

    /// Start continuous location updates
    func startUpdating()

    /// Stop continuous location updates
    func stopUpdating()
}

// MARK: - Image Cache Service Protocol

/// Protocol for image caching
@MainActor
protocol ImageCacheServiceProtocol: ObservableObject {
    /// Download progress (0.0 to 1.0)
    var downloadProgress: Double { get }

    /// Whether download is in progress
    var isDownloading: Bool { get }

    /// Total images to download
    var totalImages: Int { get }

    /// Number of downloaded images
    var downloadedImages: Int { get }

    /// Last cache update date
    var lastCacheUpdate: Date? { get }

    /// Current cache size in bytes
    var cacheSize: Int64 { get }

    /// Last download result message
    var lastDownloadResult: String? { get }

    /// Formatted cache size string
    var formattedCacheSize: String { get }

    /// Get image from cache or download
    func getImage(from urlString: String, retryCount: Int) async -> UIImage?

    /// Download all images for offline use
    func downloadAllImages(from sites: [Site]) async

    /// Clear the image cache
    func clearCache()

    /// Calculate current cache size
    func calculateCacheSize()

    /// Check if updates are available
    func hasUpdatesAvailable(lastContentUpdate: Date?) -> Bool
}

// MARK: - Share Service Protocol

/// Protocol for sharing functionality
@MainActor
protocol ShareServiceProtocol {
    /// Share a site
    static func shareSite(_ site: Site)

    /// Share an achievement
    static func shareAchievement(_ achievement: Achievement)

    /// Share a discovery key
    static func shareDiscoveryKey(for site: Site)

    /// Share a knowledge key
    static func shareKnowledgeKey(for subLocation: SubLocation, siteName: String)

    /// Share profile card
    static func shareProfileCard(
        rank: UserRank,
        points: Int,
        knowledgeKeys: Int,
        discoveryKeys: Int,
        achievements: Int,
        totalAchievements: Int
    )
}

// MARK: - Local Storage Protocol

/// Protocol for local data persistence
protocol LocalStorageProtocol {
    /// Save a value for a key
    func set<T: Codable>(_ value: T, forKey key: String)

    /// Get a value for a key
    func get<T: Codable>(_ type: T.Type, forKey key: String) -> T?

    /// Remove a value for a key
    func remove(forKey key: String)

    /// Check if a key exists
    func exists(forKey key: String) -> Bool
}

// MARK: - Default Local Storage Implementation

/// Default implementation using UserDefaults
final class UserDefaultsStorage: LocalStorageProtocol {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func set<T: Codable>(_ value: T, forKey key: String) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    func get<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }

    func exists(forKey key: String) -> Bool {
        defaults.object(forKey: key) != nil
    }
}

// MARK: - Protocol Conformance Extensions

extension ContentService: ContentServiceProtocol {
    var sitesPublisher: AnyPublisher<[Site], Never> {
        $sites.eraseToAnyPublisher()
    }
}

extension LocationManager: LocationServiceProtocol {}

extension ImageCacheService: ImageCacheServiceProtocol {
    func getImage(from urlString: String, retryCount: Int = 0) async -> UIImage? {
        await getImage(from: urlString, retryCount: retryCount)
    }
}

extension ShareService: ShareServiceProtocol {}
