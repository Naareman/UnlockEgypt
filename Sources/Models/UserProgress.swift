import Foundation

// MARK: - User Progress
/// Tracks the user's overall progress and achievements
class UserProgress: ObservableObject, Codable {
    @Published var unlockedSites: Set<String>
    @Published var visitedSites: Set<String>
    @Published var completedStories: Set<String>
    @Published var quizResults: [QuizResult]
    @Published var badges: [Badge]
    @Published var explorerRank: ExplorerRank

    init() {
        self.unlockedSites = []
        self.visitedSites = []
        self.completedStories = []
        self.quizResults = []
        self.badges = []
        self.explorerRank = .novice
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case unlockedSites, visitedSites, completedStories, quizResults, badges, explorerRank
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        unlockedSites = try container.decode(Set<String>.self, forKey: .unlockedSites)
        visitedSites = try container.decode(Set<String>.self, forKey: .visitedSites)
        completedStories = try container.decode(Set<String>.self, forKey: .completedStories)
        quizResults = try container.decode([QuizResult].self, forKey: .quizResults)
        badges = try container.decode([Badge].self, forKey: .badges)
        explorerRank = try container.decode(ExplorerRank.self, forKey: .explorerRank)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(unlockedSites, forKey: .unlockedSites)
        try container.encode(visitedSites, forKey: .visitedSites)
        try container.encode(completedStories, forKey: .completedStories)
        try container.encode(quizResults, forKey: .quizResults)
        try container.encode(badges, forKey: .badges)
        try container.encode(explorerRank, forKey: .explorerRank)
    }

    // MARK: - Progress Methods
    func unlockSite(_ siteId: String) {
        unlockedSites.insert(siteId)
        checkForNewBadges()
    }

    func markSiteVisited(_ siteId: String) {
        visitedSites.insert(siteId)
        checkForNewBadges()
    }

    func completeStory(_ storyId: String) {
        completedStories.insert(storyId)
        checkForNewBadges()
    }

    func addQuizResult(_ result: QuizResult) {
        quizResults.append(result)
        checkForNewBadges()
        updateExplorerRank()
    }

    private func checkForNewBadges() {
        // First site visited
        if visitedSites.count >= 1 && !badges.contains(where: { $0.type == .firstSteps }) {
            badges.append(Badge(type: .firstSteps, dateEarned: Date()))
        }

        // Completed 5 stories
        if completedStories.count >= 5 && !badges.contains(where: { $0.type == .storyteller }) {
            badges.append(Badge(type: .storyteller, dateEarned: Date()))
        }

        // Perfect quiz score
        if quizResults.contains(where: { $0.percentage == 100 }) && !badges.contains(where: { $0.type == .scholar }) {
            badges.append(Badge(type: .scholar, dateEarned: Date()))
        }

        // Visited pyramids of Giza
        if visitedSites.contains("giza") && !badges.contains(where: { $0.type == .pyramidExplorer }) {
            badges.append(Badge(type: .pyramidExplorer, dateEarned: Date()))
        }
    }

    private func updateExplorerRank() {
        let totalPoints = (visitedSites.count * 10) + (completedStories.count * 20) + (quizResults.filter { $0.passed }.count * 15)

        explorerRank = ExplorerRank.forPoints(totalPoints)
    }
}

// MARK: - Badge
struct Badge: Identifiable, Codable, Equatable {
    var id: String { type.rawValue }
    let type: BadgeType
    let dateEarned: Date
}

enum BadgeType: String, Codable {
    case firstSteps = "First Steps"
    case storyteller = "Storyteller"
    case scholar = "Scholar"
    case pyramidExplorer = "Pyramid Explorer"
    case nileNavigator = "Nile Navigator"
    case templeSeeker = "Temple Seeker"
    case historyBuff = "History Buff"
    case egyptologist = "Egyptologist"

    var icon: String {
        switch self {
        case .firstSteps: return "figure.walk"
        case .storyteller: return "book.fill"
        case .scholar: return "graduationcap.fill"
        case .pyramidExplorer: return "triangle.fill"
        case .nileNavigator: return "water.waves"
        case .templeSeeker: return "building.columns.fill"
        case .historyBuff: return "clock.fill"
        case .egyptologist: return "star.fill"
        }
    }

    var description: String {
        switch self {
        case .firstSteps: return "Visited your first historical site"
        case .storyteller: return "Completed 5 stories"
        case .scholar: return "Achieved a perfect quiz score"
        case .pyramidExplorer: return "Visited the Pyramids of Giza"
        case .nileNavigator: return "Visited 3 sites along the Nile"
        case .templeSeeker: return "Visited 5 ancient temples"
        case .historyBuff: return "Completed stories from all eras"
        case .egyptologist: return "Reached the highest explorer rank"
        }
    }
}

// MARK: - Explorer Rank
enum ExplorerRank: String, Codable {
    case novice = "Novice Explorer"
    case curious = "Curious Traveler"
    case dedicated = "Dedicated Seeker"
    case experienced = "Experienced Explorer"
    case expert = "Expert Historian"
    case master = "Master Egyptologist"

    var icon: String {
        switch self {
        case .novice: return "1.circle.fill"
        case .curious: return "2.circle.fill"
        case .dedicated: return "3.circle.fill"
        case .experienced: return "4.circle.fill"
        case .expert: return "5.circle.fill"
        case .master: return "star.circle.fill"
        }
    }

    var requiredPoints: Int {
        switch self {
        case .novice: return 0
        case .curious: return 50
        case .dedicated: return 150
        case .experienced: return 300
        case .expert: return 500
        case .master: return 1000
        }
    }

    static func forPoints(_ points: Int) -> ExplorerRank {
        if points >= ExplorerRank.master.requiredPoints { return .master }
        if points >= ExplorerRank.expert.requiredPoints { return .expert }
        if points >= ExplorerRank.experienced.requiredPoints { return .experienced }
        if points >= ExplorerRank.dedicated.requiredPoints { return .dedicated }
        if points >= ExplorerRank.curious.requiredPoints { return .curious }
        return .novice
    }
}
