import SwiftUI
import Combine
import CoreLocation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var sites: [Site] = []
    @Published var totalPoints: Int = 0
    @Published var discoveredPlaces: [String: Date] = [:]  // placeId -> last visit date
    @Published var completedQuizzes: Set<String> = []
    @Published var completedSubLocations: Set<String> = []
    @Published var isLoading: Bool = false

    // MARK: - Two-Badge System (Keys)
    /// Knowledge Keys: sublocation IDs where user completed all story cards
    @Published var scholarBadges: Set<String> = []
    /// Discovery Keys: site IDs where user physically visited (location verified)
    @Published var explorerBadges: Set<String> = []
    /// Tracks when each site was physically visited
    @Published var verifiedVisits: [String: Date] = [:]
    /// Tracks sites that were only self-reported (can be upgraded with location verification)
    @Published var selfReportedSites: Set<String> = []

    // MARK: - Achievement System
    @Published var achievementProgress: AchievementProgress = AchievementProgress()
    @Published var recentlyUnlockedAchievement: Achievement?

    // MARK: - Achievement Caching (Performance Optimization)
    private var cachedFullyCompletedSitesCount: Int?
    private var cachedNextAchievement: (achievement: Achievement, progress: Int, required: Int)?
    private var achievementCacheValid: Bool = false

    // MARK: - Favorites
    @Published var favoriteSites: Set<String> = []

    private let contentService = ContentService.shared
    private var cancellables = Set<AnyCancellable>()

    private let pointsKey = "totalPoints"
    private let discoveredKey = "discoveredPlaces"
    private let quizzesKey = "completedQuizzes"
    private let completedKey = "completedSubLocations"
    private let scholarKey = "scholarBadges"
    private let explorerKey = "explorerBadges"
    private let verifiedVisitsKey = "verifiedVisits"
    private let selfReportedKey = "selfReportedSites"
    private let achievementsKey = "achievementProgress"
    private let favoritesKey = "favoriteSites"

    /// Days before a revisit earns points again
    private let revisitDays: Double = 30
    /// Radius in meters for location verification
    private let verificationRadius: Double = 200

    init() {
        loadData()
        loadProgress()
        setupContentSubscription()
    }

    private func setupContentSubscription() {
        // Subscribe to content updates
        contentService.$sites
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sites in
                if !sites.isEmpty {
                    self?.sites = sites
                }
            }
            .store(in: &cancellables)

        contentService.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)
    }

    private func loadData() {
        // Load from ContentService (which uses cached or sample data initially)
        sites = contentService.sites
    }

    /// Refresh content from remote
    func refreshContent() async {
        await contentService.refresh()
    }

    private func loadProgress() {
        // Load from UserDefaults
        totalPoints = UserDefaults.standard.integer(forKey: pointsKey)

        // Load discovered places with dates
        if let discoveredData = UserDefaults.standard.dictionary(forKey: discoveredKey) as? [String: Double] {
            discoveredPlaces = discoveredData.mapValues { Date(timeIntervalSince1970: $0) }
        }
        if let quizzes = UserDefaults.standard.array(forKey: quizzesKey) as? [String] {
            completedQuizzes = Set(quizzes)
        }
        if let completed = UserDefaults.standard.array(forKey: completedKey) as? [String] {
            completedSubLocations = Set(completed)
        }

        // Load badge data
        if let scholars = UserDefaults.standard.array(forKey: scholarKey) as? [String] {
            scholarBadges = Set(scholars)
        }
        if let explorers = UserDefaults.standard.array(forKey: explorerKey) as? [String] {
            explorerBadges = Set(explorers)
        }
        if let selfReported = UserDefaults.standard.array(forKey: selfReportedKey) as? [String] {
            selfReportedSites = Set(selfReported)
        }
        if let visitsData = UserDefaults.standard.dictionary(forKey: verifiedVisitsKey) as? [String: Double] {
            verifiedVisits = visitsData.mapValues { Date(timeIntervalSince1970: $0) }
        }

        // Load achievements
        if let achievementData = UserDefaults.standard.data(forKey: achievementsKey),
           let progress = try? JSONDecoder().decode(AchievementProgress.self, from: achievementData) {
            achievementProgress = progress
        }

        // Load favorites
        if let favorites = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            favoriteSites = Set(favorites)
        }
    }

    private func saveProgress() {
        UserDefaults.standard.set(totalPoints, forKey: pointsKey)
        // Save discovered places with dates as timestamps
        let discoveredData = discoveredPlaces.mapValues { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(discoveredData, forKey: discoveredKey)
        UserDefaults.standard.set(Array(completedQuizzes), forKey: quizzesKey)
        UserDefaults.standard.set(Array(completedSubLocations), forKey: completedKey)

        // Save badge data
        UserDefaults.standard.set(Array(scholarBadges), forKey: scholarKey)
        UserDefaults.standard.set(Array(explorerBadges), forKey: explorerKey)
        UserDefaults.standard.set(Array(selfReportedSites), forKey: selfReportedKey)
        let visitsData = verifiedVisits.mapValues { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(visitsData, forKey: verifiedVisitsKey)

        // Save achievements
        if let achievementData = try? JSONEncoder().encode(achievementProgress) {
            UserDefaults.standard.set(achievementData, forKey: achievementsKey)
        }

        // Save favorites
        UserDefaults.standard.set(Array(favoriteSites), forKey: favoritesKey)
    }

    // MARK: - Favorites

    func toggleFavorite(siteId: String) {
        if favoriteSites.contains(siteId) {
            favoriteSites.remove(siteId)
        } else {
            favoriteSites.insert(siteId)
        }
        saveFavorites()
    }

    func isFavorite(siteId: String) -> Bool {
        favoriteSites.contains(siteId)
    }

    var favoriteSitesList: [Site] {
        sites.filter { favoriteSites.contains($0.id) }
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteSites), forKey: favoritesKey)
    }

    // MARK: - Gamification

    /// Award 1 point for discovering a place (or revisiting after 30 days)
    func discoverPlace(_ placeId: String) {
        let now = Date()

        if let lastVisit = discoveredPlaces[placeId] {
            // Check if 30 days have passed since last visit
            let daysSinceVisit = now.timeIntervalSince(lastVisit) / (60 * 60 * 24)
            if daysSinceVisit >= revisitDays {
                // Revisit after 30 days - award point again
                discoveredPlaces[placeId] = now
                addPoints(1)
                saveProgress()
            }
            // Otherwise, no points (visited recently)
        } else {
            // First time visit
            discoveredPlaces[placeId] = now
            addPoints(1)
            saveProgress()
        }
    }

    /// Award 10 points for correct quiz answer
    func correctQuizAnswer(_ quizId: String) {
        if !completedQuizzes.contains(quizId) {
            completedQuizzes.insert(quizId)
            addPoints(10)
            invalidateAchievementCache()
            saveProgress()
            checkAndAwardAchievements()
        }
    }

    /// Mark a sub-location as completed (for backward compatibility)
    func completeSubLocation(_ subLocationId: String) {
        if !completedSubLocations.contains(subLocationId) {
            completedSubLocations.insert(subLocationId)
            saveProgress()
        }
    }

    /// Check if a sub-location is completed (for backward compatibility)
    func isSubLocationCompleted(_ subLocationId: String) -> Bool {
        completedSubLocations.contains(subLocationId)
    }

    private func addPoints(_ points: Int) {
        withAnimation {
            totalPoints += points
        }
    }

    // MARK: - Two-Badge System

    /// Award Knowledge Key when user completes all story cards for a sublocation
    /// Awards 1 point for completing stories
    func awardScholarBadge(for subLocationId: String) {
        guard !scholarBadges.contains(subLocationId) else { return }

        scholarBadges.insert(subLocationId)
        completedSubLocations.insert(subLocationId) // For backward compatibility
        addPoints(1)
        invalidateAchievementCache()
        saveProgress()
        checkAndAwardAchievements()
    }

    /// Check if user has Scholar badge for a sublocation
    func hasScholarBadge(for subLocationId: String) -> Bool {
        scholarBadges.contains(subLocationId)
    }

    /// Verify user's location and award Explorer badge if within range
    /// Awards 50 points for verified visit, 30 points for self-reported visit
    /// Returns: (success, message, pointsAwarded)
    func verifyAndAwardExplorerBadge(for site: Site, userLocation: CLLocation?) -> (Bool, String, Int) {
        let siteId = site.id
        let now = Date()

        // Check if already location-verified (not just self-reported) and 30 days haven't passed
        let wasLocationVerified = explorerBadges.contains(siteId) && !selfReportedSites.contains(siteId)
        if wasLocationVerified, let lastVisit = verifiedVisits[siteId] {
            let daysSinceVisit = now.timeIntervalSince(lastVisit) / (60 * 60 * 24)
            if daysSinceVisit < revisitDays {
                let daysRemaining = Int(revisitDays - daysSinceVisit)
                return (false, "You've already visited! Come back in \(daysRemaining) days for bonus points.", 0)
            }
        }

        // If user has location, verify it
        if let userLocation = userLocation {
            let siteLocation = site.location
            let distance = userLocation.distance(from: siteLocation)

            if distance <= verificationRadius {
                // Check if upgrading from self-report
                if selfReportedSites.contains(siteId) {
                    // Upgrade from self-report: give delta (20 points)
                    selfReportedSites.remove(siteId)
                    verifiedVisits[siteId] = now
                    addPoints(20)
                    invalidateAchievementCache()
                    saveProgress()
                    checkAndAwardAchievements()
                    return (true, "Location verified! +20 bonus points!", 20)
                } else {
                    // Fresh location verification: 50 points
                    explorerBadges.insert(siteId)
                    verifiedVisits[siteId] = now
                    addPoints(50)
                    invalidateAchievementCache()
                    saveProgress()
                    checkAndAwardAchievements()
                    return (true, "Amazing! +50 points for visiting \(site.name)!", 50)
                }
            } else {
                let distanceKm = distance / 1000
                return (false, String(format: "You're %.1f km away. Get closer to %@ to verify!", distanceKm, site.name), 0)
            }
        } else {
            // No location available
            return (false, "Can't get your location. Try again or tap 'Mark as Visited'!", 0)
        }
    }

    /// Self-report a visit without location verification (awards fewer points)
    func selfReportVisit(for siteId: String) -> (Bool, String, Int) {
        let now = Date()

        // Check if already has badge (either way)
        if explorerBadges.contains(siteId) {
            if selfReportedSites.contains(siteId) {
                // Already self-reported, suggest location verification
                return (false, "Already marked! Verify your location for +20 bonus!", 0)
            } else {
                // Already location-verified
                if let lastVisit = verifiedVisits[siteId] {
                    let daysSinceVisit = now.timeIntervalSince(lastVisit) / (60 * 60 * 24)
                    if daysSinceVisit < revisitDays {
                        let daysRemaining = Int(revisitDays - daysSinceVisit)
                        return (false, "Already visited! Come back in \(daysRemaining) days.", 0)
                    }
                }
            }
        }

        // Self-reported visit - award 30 points
        explorerBadges.insert(siteId)
        selfReportedSites.insert(siteId)
        verifiedVisits[siteId] = now
        addPoints(30)
        invalidateAchievementCache()
        saveProgress()
        checkAndAwardAchievements()
        return (true, "You earned +30 points!", 30)
    }

    /// Check if user has Explorer badge for a site
    func hasExplorerBadge(for siteId: String) -> Bool {
        explorerBadges.contains(siteId)
    }

    /// Check if site is fully completed (both Scholar for all sublocations AND Explorer)
    func isSiteFullyCompleted(site: Site) -> Bool {
        guard hasExplorerBadge(for: site.id) else { return false }

        // Check all sublocations have Scholar badge
        guard let subLocations = site.subLocations, !subLocations.isEmpty else {
            return true // No sublocations, just need Explorer
        }

        return subLocations.allSatisfy { hasScholarBadge(for: $0.id) }
    }

    /// Get completion status for a sublocation
    /// Returns: (hasScholarBadge, hasExplorerBadgeForSite, isFullyCompleted)
    func getSubLocationStatus(subLocationId: String, siteId: String) -> (scholar: Bool, explorer: Bool, complete: Bool) {
        let scholar = hasScholarBadge(for: subLocationId)
        let explorer = hasExplorerBadge(for: siteId)
        return (scholar, explorer, scholar && explorer)
    }

    // MARK: - Reset (for testing)
    func resetProgress() {
        totalPoints = 0
        discoveredPlaces = [:]
        completedQuizzes.removeAll()
        completedSubLocations.removeAll()
        scholarBadges.removeAll()
        explorerBadges.removeAll()
        selfReportedSites.removeAll()
        verifiedVisits = [:]
        achievementProgress = AchievementProgress()
        recentlyUnlockedAchievement = nil
        saveProgress()
    }

    // MARK: - Achievement System

    /// Current user rank based on points
    var currentRank: UserRank {
        UserRank.rank(for: totalPoints)
    }

    /// Points needed to reach next rank
    var pointsToNextRank: Int? {
        currentRank.pointsToNextRank(currentPoints: totalPoints)
    }

    /// Progress percentage to next rank (0.0 to 1.0)
    var rankProgress: Double {
        let rank = currentRank
        guard let maxPoints = rank.maxPoints else { return 1.0 } // Pharaoh = 100%
        let minPoints = rank.minPoints
        let range = maxPoints - minPoints
        let progress = totalPoints - minPoints
        return Double(progress) / Double(range)
    }

    /// Number of unlocked achievements
    var unlockedAchievementsCount: Int {
        achievementProgress.unlockedAchievements.count
    }

    /// All unlocked achievements
    var unlockedAchievements: [Achievement] {
        Achievements.all.filter { achievementProgress.isUnlocked($0.id) }
    }

    /// All locked achievements
    var lockedAchievements: [Achievement] {
        Achievements.all.filter { !achievementProgress.isUnlocked($0.id) }
    }

    /// Get the next achievement the user is closest to unlocking (cached for performance)
    var nextAchievementToUnlock: (achievement: Achievement, progress: Int, required: Int)? {
        // Return cached value if valid
        if achievementCacheValid, let cached = cachedNextAchievement {
            return cached
        }

        // Calculate and cache
        for achievement in Achievements.all {
            guard !achievementProgress.isUnlocked(achievement.id) else { continue }

            let (progress, required) = getAchievementProgress(achievement)
            if required > 0 && progress < required {
                cachedNextAchievement = (achievement, progress, required)
                achievementCacheValid = true
                return cachedNextAchievement
            }
        }
        cachedNextAchievement = nil
        achievementCacheValid = true
        return nil
    }

    /// Invalidate achievement cache when relevant data changes
    private func invalidateAchievementCache() {
        achievementCacheValid = false
        cachedNextAchievement = nil
        cachedFullyCompletedSitesCount = nil
    }

    /// Get count of fully completed sites (cached for performance)
    private func getFullyCompletedSitesCount() -> Int {
        if let cached = cachedFullyCompletedSitesCount {
            return cached
        }
        let count = sites.filter { isSiteFullyCompleted(site: $0) }.count
        cachedFullyCompletedSitesCount = count
        return count
    }

    /// Get progress for a specific achievement
    func getAchievementProgress(_ achievement: Achievement) -> (current: Int, required: Int) {
        switch achievement.id {
        // Exploration achievements
        case "first_discovery", "curious_traveler", "dedicated_explorer":
            return (getFullyCompletedSitesCount(), achievement.requirement)

        case "master_explorer":
            return (getFullyCompletedSitesCount(), sites.count)

        // Knowledge achievements
        case "first_secret", "eager_learner", "knowledge_seeker":
            return (scholarBadges.count, achievement.requirement)

        // Quiz achievements
        case "quiz_starter", "quiz_apprentice", "quiz_master":
            return (completedQuizzes.count, achievement.requirement)

        // Special achievements
        case "city_champion":
            // Check if any city is fully completed
            for city in City.allCases {
                let citySites = sites.filter { $0.city == city }
                if !citySites.isEmpty && citySites.allSatisfy({ isSiteFullyCompleted(site: $0) }) {
                    return (1, 1) // Completed
                }
            }
            return (0, 1)

        case "era_expert":
            // Check if any era is fully completed
            for era in Era.allCases {
                let eraSites = sites.filter { $0.era == era }
                if !eraSites.isEmpty && eraSites.allSatisfy({ isSiteFullyCompleted(site: $0) }) {
                    return (1, 1) // Completed
                }
            }
            return (0, 1)

        case "true_pharaoh":
            let fullyCompletedSites = sites.filter { isSiteFullyCompleted(site: $0) }.count
            return (fullyCompletedSites, sites.count)

        default:
            return (0, achievement.requirement)
        }
    }

    /// Check and award any newly earned achievements
    func checkAndAwardAchievements() {
        for achievement in Achievements.all {
            guard !achievementProgress.isUnlocked(achievement.id) else { continue }

            let (current, required) = getAchievementProgress(achievement)
            if required > 0 && current >= required {
                // Achievement unlocked!
                achievementProgress.unlock(achievement.id)
                addPoints(achievement.points)
                recentlyUnlockedAchievement = achievement
                saveProgress()
            }
        }
    }

    /// Dismiss the recently unlocked achievement notification
    func dismissAchievementNotification() {
        recentlyUnlockedAchievement = nil
    }

    /// Get encouragement message for home screen
    var encouragementMessage: String {
        if let next = nextAchievementToUnlock {
            let remaining = next.required - next.progress
            if remaining == 1 {
                return "You're 1 away from unlocking \"\(next.achievement.name)\"!"
            } else {
                return "Unlock \(remaining) more to earn \"\(next.achievement.name)\""
            }
        } else if unlockedAchievementsCount == Achievements.all.count {
            return "Congratulations! You've unlocked all achievements!"
        } else {
            return "Start exploring to unlock achievements!"
        }
    }

    /// Count of fully unlocked sites (both keys)
    var fullyUnlockedSitesCount: Int {
        sites.filter { isSiteFullyCompleted(site: $0) }.count
    }

}
