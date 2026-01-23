import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var sites: [Site] = []
    @Published var totalPoints: Int = 0
    @Published var discoveredPlaces: Set<String> = []
    @Published var completedQuizzes: Set<String> = []
    @Published var completedSubLocations: Set<String> = []
    @Published var isLoading: Bool = false

    private let contentService = ContentService.shared
    private var cancellables = Set<AnyCancellable>()

    private let pointsKey = "totalPoints"
    private let discoveredKey = "discoveredPlaces"
    private let quizzesKey = "completedQuizzes"
    private let completedKey = "completedSubLocations"

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
            .assign(to: &$isLoading)
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

        if let discovered = UserDefaults.standard.array(forKey: discoveredKey) as? [String] {
            discoveredPlaces = Set(discovered)
        }
        if let quizzes = UserDefaults.standard.array(forKey: quizzesKey) as? [String] {
            completedQuizzes = Set(quizzes)
        }
        if let completed = UserDefaults.standard.array(forKey: completedKey) as? [String] {
            completedSubLocations = Set(completed)
        }
    }

    private func saveProgress() {
        UserDefaults.standard.set(totalPoints, forKey: pointsKey)
        UserDefaults.standard.set(Array(discoveredPlaces), forKey: discoveredKey)
        UserDefaults.standard.set(Array(completedQuizzes), forKey: quizzesKey)
        UserDefaults.standard.set(Array(completedSubLocations), forKey: completedKey)
    }

    // MARK: - Gamification

    /// Award 1 point for discovering a new place (story card)
    func discoverPlace(_ placeId: String) {
        if !discoveredPlaces.contains(placeId) {
            discoveredPlaces.insert(placeId)
            addPoints(1)
            saveProgress()
        }
    }

    /// Award 10 points for correct quiz answer
    func correctQuizAnswer(_ quizId: String) {
        if !completedQuizzes.contains(quizId) {
            completedQuizzes.insert(quizId)
            addPoints(10)
            saveProgress()
        }
    }

    /// Mark a sub-location as completed
    func completeSubLocation(_ subLocationId: String) {
        if !completedSubLocations.contains(subLocationId) {
            completedSubLocations.insert(subLocationId)
            saveProgress()
        }
    }

    /// Check if a sub-location is completed
    func isSubLocationCompleted(_ subLocationId: String) -> Bool {
        completedSubLocations.contains(subLocationId)
    }

    private func addPoints(_ points: Int) {
        withAnimation {
            totalPoints += points
        }
    }

    // MARK: - Reset (for testing)
    func resetProgress() {
        totalPoints = 0
        discoveredPlaces.removeAll()
        completedQuizzes.removeAll()
        completedSubLocations.removeAll()
        saveProgress()
    }

}
