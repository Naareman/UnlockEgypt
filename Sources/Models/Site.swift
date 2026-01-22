import Foundation
import CoreLocation

// MARK: - Site Model
/// Represents a historical site in Egypt
struct Site: Identifiable, Codable {
    let id: String
    let name: String
    let arabicName: String
    let era: Era
    let shortDescription: String
    let coordinates: Coordinates
    let imageNames: [String]
    let stories: [Story]
    let quiz: Quiz?
    let visitInfo: VisitInfo
    let isUnlocked: Bool

    // Computed property for distance calculation (will be used with user location)
    var location: CLLocation {
        CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
}

// MARK: - Supporting Types
struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
}

struct VisitInfo: Codable {
    let estimatedDuration: String      // e.g., "2-3 hours"
    let bestTimeToVisit: String        // e.g., "Early morning or late afternoon"
    let tips: [String]
    let arabicPhrases: [ArabicPhrase]
}

struct ArabicPhrase: Identifiable, Codable {
    var id: String { english }
    let english: String
    let arabic: String
    let pronunciation: String
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

    var color: String {
        switch self {
        case .preDynastic: return "eraPreDynastic"
        case .oldKingdom: return "eraOldKingdom"
        case .middleKingdom: return "eraMiddleKingdom"
        case .newKingdom: return "eraNewKingdom"
        case .latePeriod: return "eraLatePeriod"
        case .ptolemaic: return "eraPtolemaic"
        case .roman: return "eraRoman"
        case .islamic: return "eraIslamic"
        case .modern: return "eraModern"
        }
    }
}
