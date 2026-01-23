import Foundation
import CoreLocation

// MARK: - Site Model
/// Represents a historical site in Egypt
struct Site: Identifiable, Codable {
    let id: String
    let name: String
    let arabicName: String
    let era: Era
    let tourismType: TourismType
    let placeType: PlaceType
    let city: City
    let shortDescription: String
    let coordinates: Coordinates
    let imageNames: [String]
    let subLocations: [SubLocation]?  // For complex sites like Giza
    let visitInfo: VisitInfo
    let isUnlocked: Bool

    // Computed property for distance calculation
    var location: CLLocation {
        CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
}

// MARK: - Sub-Location (for complex sites)
/// A point of interest within a larger site
struct SubLocation: Identifiable, Codable {
    let id: String
    let name: String
    let arabicName: String
    let shortDescription: String
    let imageName: String?
    let storyCards: [StoryCard]
}

// MARK: - Story Card (new bite-sized format)
/// A single card in the story flow - can be content, fact, or quiz
struct StoryCard: Identifiable, Codable {
    let id: String
    let type: StoryCardType
    let imageName: String?
    let content: String?           // For text cards
    let funFact: String?           // For "Did you know?" cards
    let quizQuestion: QuizQuestion? // For quiz cards
}

enum StoryCardType: String, Codable {
    case intro          // Opening card with main image
    case story          // Short story paragraph with image
    case fact           // "Did you know?" fact
    case quiz           // Embedded quiz question
    case summary        // Closing card
}

// MARK: - Supporting Types
struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
}

struct VisitInfo: Codable {
    let estimatedDuration: String
    let bestTimeToVisit: String
    let tips: [String]
    let arabicPhrases: [ArabicPhrase]
}

struct ArabicPhrase: Identifiable, Codable {
    var id: String { english }
    let english: String
    let arabic: String
    let pronunciation: String
}

// MARK: - Quiz Question
struct QuizQuestion: Identifiable, Codable {
    let id: String
    let question: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String
    let funFact: String?
}

// MARK: - Tourism Type
enum TourismType: String, Codable, CaseIterable {
    case pharaonic = "Pharaonic"
    case grecoRoman = "Greco-Roman"
    case coptic = "Coptic"
    case islamic = "Islamic"
    case modern = "Modern"
}

// MARK: - Place Type
enum PlaceType: String, Codable, CaseIterable {
    case pyramid = "Pyramid"
    case temple = "Temple"
    case tomb = "Tomb"
    case museum = "Museum"
    case mosque = "Mosque"
    case church = "Church"
    case fortress = "Fortress"
    case market = "Market"
    case monument = "Monument"
    case ruins = "Ruins"

    var icon: String {
        switch self {
        case .pyramid: return "triangle.fill"
        case .temple: return "building.columns.fill"
        case .tomb: return "square.stack.3d.down.right.fill"
        case .museum: return "building.fill"
        case .mosque: return "moon.stars.fill"
        case .church: return "cross.fill"
        case .fortress: return "shield.fill"
        case .market: return "bag.fill"
        case .monument: return "star.fill"
        case .ruins: return "square.on.square.dashed"
        }
    }
}

// MARK: - City/Region
enum City: String, Codable, CaseIterable {
    case cairo = "Cairo"
    case giza = "Giza"
    case luxor = "Luxor"
    case aswan = "Aswan"
    case alexandria = "Alexandria"
    case sinai = "Sinai"
    case fayoum = "Fayoum"
    case dahab = "Dahab"
    case hurghada = "Hurghada"
    case sharmElSheikh = "Sharm El Sheikh"
}

// MARK: - Era Enum
enum Era: String, Codable, CaseIterable {
    case preDynastic = "Pre-Dynastic"
    case oldKingdom = "Old Kingdom"
    case middleKingdom = "Middle Kingdom"
    case newKingdom = "New Kingdom"
    case latePeriod = "Late Period"
    case ptolemaic = "Ptolemaic"
    case roman = "Roman"
    case islamic = "Islamic"
    case modern = "Modern"

    var yearRange: String {
        switch self {
        case .preDynastic: return "Before 3100 BCE"
        case .oldKingdom: return "2686-2181 BCE"
        case .middleKingdom: return "2055-1650 BCE"
        case .newKingdom: return "1550-1077 BCE"
        case .latePeriod: return "664-332 BCE"
        case .ptolemaic: return "332-30 BCE"
        case .roman: return "30 BCE-641 CE"
        case .islamic: return "641-1517 CE"
        case .modern: return "1517 CE-Present"
        }
    }

}
