import Foundation

// MARK: - Achievement Definition
struct Achievement: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let requirement: Int
    let points: Int

    var unlockedDescription: String {
        "You've unlocked: \(name)!"
    }
}

// MARK: - Achievement Category
enum AchievementCategory: String, Codable, CaseIterable {
    case exploration = "Exploration"
    case knowledge = "Knowledge"
    case mastery = "Mastery"

    var icon: String {
        switch self {
        case .exploration: return "map"
        case .knowledge: return "book"
        case .mastery: return "crown"
        }
    }
}

// MARK: - User Rank
enum UserRank: String, CaseIterable {
    case tourist = "Tourist"
    case traveler = "Traveler"
    case explorer = "Explorer"
    case historian = "Historian"
    case archaeologist = "Archaeologist"
    case pharaoh = "Pharaoh"

    var icon: String {
        switch self {
        case .tourist: return "figure.walk"
        case .traveler: return "airplane"
        case .explorer: return "binoculars"
        case .historian: return "scroll"
        case .archaeologist: return "hammer"
        case .pharaoh: return "crown.fill"
        }
    }

    var minPoints: Int {
        switch self {
        case .tourist: return 0
        case .traveler: return 51
        case .explorer: return 151
        case .historian: return 301
        case .archaeologist: return 501
        case .pharaoh: return 801
        }
    }

    var maxPoints: Int? {
        switch self {
        case .tourist: return 50
        case .traveler: return 150
        case .explorer: return 300
        case .historian: return 500
        case .archaeologist: return 800
        case .pharaoh: return nil
        }
    }

    static func rank(for points: Int) -> UserRank {
        if points >= 801 { return .pharaoh }
        if points >= 501 { return .archaeologist }
        if points >= 301 { return .historian }
        if points >= 151 { return .explorer }
        if points >= 51 { return .traveler }
        return .tourist
    }

    var next: UserRank? {
        switch self {
        case .tourist: return .traveler
        case .traveler: return .explorer
        case .explorer: return .historian
        case .historian: return .archaeologist
        case .archaeologist: return .pharaoh
        case .pharaoh: return nil
        }
    }

    func pointsToNextRank(currentPoints: Int) -> Int? {
        guard let nextRank = next else { return nil }
        return nextRank.minPoints - currentPoints
    }
}

// MARK: - All Available Achievements
struct Achievements {
    static let all: [Achievement] = [
        // EXPLORATION - Visiting sites
        Achievement(
            id: "first_discovery",
            name: "First Discovery",
            description: "Unlock your first site",
            icon: "key.fill",
            category: .exploration,
            requirement: 1,
            points: 10
        ),
        Achievement(
            id: "curious_traveler",
            name: "Curious Traveler",
            description: "Unlock 3 sites",
            icon: "map.fill",
            category: .exploration,
            requirement: 3,
            points: 25
        ),
        Achievement(
            id: "dedicated_explorer",
            name: "Dedicated Explorer",
            description: "Unlock 5 sites",
            icon: "safari.fill",
            category: .exploration,
            requirement: 5,
            points: 50
        ),
        Achievement(
            id: "master_explorer",
            name: "Master Explorer",
            description: "Unlock all sites",
            icon: "globe.americas.fill",
            category: .exploration,
            requirement: -1, // Special: all sites
            points: 100
        ),

        // KNOWLEDGE - Completing stories
        Achievement(
            id: "first_secret",
            name: "First Secret",
            description: "Unlock your first Knowledge Key",
            icon: "book.fill",
            category: .knowledge,
            requirement: 1,
            points: 10
        ),
        Achievement(
            id: "eager_learner",
            name: "Eager Learner",
            description: "Earn 5 Knowledge Keys",
            icon: "books.vertical.fill",
            category: .knowledge,
            requirement: 5,
            points: 25
        ),
        Achievement(
            id: "knowledge_seeker",
            name: "Knowledge Seeker",
            description: "Earn 10 Knowledge Keys",
            icon: "text.book.closed.fill",
            category: .knowledge,
            requirement: 10,
            points: 50
        ),

        // MASTERY - Quizzes and completion
        Achievement(
            id: "quiz_starter",
            name: "Quiz Starter",
            description: "Answer your first quiz correctly",
            icon: "questionmark.circle.fill",
            category: .mastery,
            requirement: 1,
            points: 10
        ),
        Achievement(
            id: "quiz_apprentice",
            name: "Quiz Apprentice",
            description: "Answer 5 quizzes correctly",
            icon: "brain.head.profile",
            category: .mastery,
            requirement: 5,
            points: 25
        ),
        Achievement(
            id: "quiz_master",
            name: "Quiz Master",
            description: "Answer 10 quizzes correctly",
            icon: "graduationcap.fill",
            category: .mastery,
            requirement: 10,
            points: 50
        ),
        Achievement(
            id: "city_champion",
            name: "City Champion",
            description: "Fully unlock all sites in one city",
            icon: "building.2.fill",
            category: .mastery,
            requirement: -2, // Special: complete a city
            points: 75
        ),
        Achievement(
            id: "era_expert",
            name: "Era Expert",
            description: "Unlock all sites from one historical period",
            icon: "clock.fill",
            category: .mastery,
            requirement: -3, // Special: complete an era
            points: 75
        ),
        Achievement(
            id: "true_pharaoh",
            name: "True Pharaoh",
            description: "Achieve 100% completion",
            icon: "crown.fill",
            category: .mastery,
            requirement: -4, // Special: 100% completion
            points: 200
        ),
    ]

    static func achievement(for id: String) -> Achievement? {
        all.first { $0.id == id }
    }
}

// MARK: - Achievement Progress
struct AchievementProgress: Codable {
    var unlockedAchievements: Set<String> = []
    var achievementUnlockDates: [String: Date] = [:]

    mutating func unlock(_ achievementId: String) {
        guard !unlockedAchievements.contains(achievementId) else { return }
        unlockedAchievements.insert(achievementId)
        achievementUnlockDates[achievementId] = Date()
    }

    func isUnlocked(_ achievementId: String) -> Bool {
        unlockedAchievements.contains(achievementId)
    }

    func unlockDate(for achievementId: String) -> Date? {
        achievementUnlockDates[achievementId]
    }
}
