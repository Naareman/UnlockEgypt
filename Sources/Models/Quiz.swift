import Foundation

// MARK: - Quiz Model
/// A quiz associated with a site or story
struct Quiz: Identifiable, Codable {
    let id: String
    let title: String
    let questions: [QuizQuestion]
    let passingScore: Int            // Minimum correct answers to "pass"

    var totalQuestions: Int { questions.count }
}

// MARK: - Quiz Question
struct QuizQuestion: Identifiable, Codable {
    let id: String
    let question: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String          // Shown after answering
    let funFact: String?             // Additional interesting info
}

// MARK: - Quiz Result
struct QuizResult: Identifiable, Codable {
    var id: String { "\(quizId)-\(dateTaken.timeIntervalSince1970)" }
    let quizId: String
    let siteId: String
    let score: Int
    let totalQuestions: Int
    let dateTaken: Date

    var percentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(score) / Double(totalQuestions) * 100
    }

    var passed: Bool {
        percentage >= 70
    }

    var badge: QuizBadge {
        switch percentage {
        case 100: return .perfect
        case 80..<100: return .excellent
        case 70..<80: return .good
        default: return .tryAgain
        }
    }
}

// MARK: - Quiz Badge
enum QuizBadge: String, Codable {
    case perfect = "Perfect"
    case excellent = "Excellent"
    case good = "Good"
    case tryAgain = "Keep Learning"

    var icon: String {
        switch self {
        case .perfect: return "star.fill"
        case .excellent: return "hand.thumbsup.fill"
        case .good: return "checkmark.circle.fill"
        case .tryAgain: return "book.fill"
        }
    }

    var message: String {
        switch self {
        case .perfect: return "You're a true Egyptologist!"
        case .excellent: return "Excellent knowledge!"
        case .good: return "Well done, explorer!"
        case .tryAgain: return "Read the story again and try once more!"
        }
    }
}
