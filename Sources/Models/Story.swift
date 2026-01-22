import Foundation

// MARK: - Story Model
/// A narrative piece about a historical site or event
struct Story: Identifiable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let chapters: [Chapter]
    let audioFileName: String?       // Optional audio narration
    let estimatedReadTime: Int       // In minutes
    let perspective: Perspective     // Whose viewpoint is this story from?

    var totalChapters: Int { chapters.count }
}

// MARK: - Chapter
/// A section within a story
struct Chapter: Identifiable, Codable {
    let id: String
    let title: String
    let content: String              // The actual story text
    let imageName: String?
    let didYouKnow: String?          // Fun fact callout
}

// MARK: - Perspective
/// The narrative viewpoint of a story
enum Perspective: String, Codable {
    case pharaoh = "Pharaoh"
    case priest = "Priest"
    case worker = "Worker"
    case explorer = "Explorer"
    case historian = "Historian"
    case merchant = "Merchant"
    case scribe = "Scribe"

    var icon: String {
        switch self {
        case .pharaoh: return "crown.fill"
        case .priest: return "sparkles"
        case .worker: return "hammer.fill"
        case .explorer: return "binoculars.fill"
        case .historian: return "book.fill"
        case .merchant: return "bag.fill"
        case .scribe: return "pencil.and.outline"
        }
    }

    var description: String {
        switch self {
        case .pharaoh: return "Experience through the eyes of royalty"
        case .priest: return "Discover the sacred mysteries"
        case .worker: return "Feel the toil of the builders"
        case .explorer: return "Join the adventure of discovery"
        case .historian: return "Learn the scholarly perspective"
        case .merchant: return "Travel the ancient trade routes"
        case .scribe: return "Record history as it unfolds"
        }
    }
}

// MARK: - Story Progress (for tracking user progress)
struct StoryProgress: Identifiable, Codable {
    var id: String { storyId }
    let storyId: String
    var currentChapter: Int
    var isCompleted: Bool
    var lastReadDate: Date

    var progressPercentage: Double {
        // Will be calculated based on total chapters
        0.0
    }
}
