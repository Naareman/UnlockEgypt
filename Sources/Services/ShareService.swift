import SwiftUI
import UIKit

/// Service for sharing content from the app
struct ShareService {

    /// Published error for UI to observe
    @MainActor static var lastError: String?

    /// Callback for share completion/error
    typealias ShareCompletion = (Bool, String?) -> Void

    // MARK: - Share Site

    @MainActor
    static func shareSite(_ site: Site) {
        let text = """
        🏛️ \(site.name)
        \(site.arabicName)

        \(site.shortDescription)

        📍 \(site.city.rawValue), Egypt
        🏺 \(site.era.rawValue) • \(site.placeType.rawValue)

        Discover it on Unlock Egypt!
        """

        share(text: text)
    }

    // MARK: - Share Achievement

    @MainActor
    static func shareAchievement(_ achievement: Achievement) {
        let text = """
        🏆 Achievement Unlocked!

        I just earned "\(achievement.name)" on Unlock Egypt!

        \(achievement.description)

        +\(achievement.points) points

        #UnlockEgypt #AncientHistory
        """

        share(text: text)
    }

    // MARK: - Share Discovery Key

    @MainActor
    static func shareDiscoveryKey(for site: Site) {
        let text = """
        🗝️ Discovery Key Unlocked!

        I'm at \(site.name) (\(site.arabicName))!

        📍 \(site.city.rawValue), Egypt

        Unlocking Egypt's ancient secrets with Unlock Egypt!

        #UnlockEgypt #\(site.city.rawValue.replacingOccurrences(of: " ", with: ""))
        """

        share(text: text)
    }

    // MARK: - Share Knowledge Key

    @MainActor
    static func shareKnowledgeKey(for subLocation: SubLocation, siteName: String) {
        let text = """
        🗝️ Knowledge Key Unlocked!

        I've unlocked the secrets of \(subLocation.name) at \(siteName)!

        \(subLocation.shortDescription)

        Discover Egypt's Mysteries with Unlock Egypt!

        #UnlockEgypt #AncientSecrets
        """

        share(text: text)
    }

    // MARK: - Share Profile Card

    @MainActor
    static func shareProfileCard(
        rank: UserRank,
        points: Int,
        knowledgeKeys: Int,
        discoveryKeys: Int,
        achievements: Int,
        totalAchievements: Int
    ) {
        let text = """
        👑 My Unlock Egypt Journey

        🏆 Rank: \(rank.rawValue)
        ⭐ \(points) Ankh Points

        🗝️ \(knowledgeKeys) Knowledge Keys
        🗝️ \(discoveryKeys) Discovery Keys
        🏅 \(achievements)/\(totalAchievements) Achievements

        Join me in unlocking Egypt's ancient secrets!

        #UnlockEgypt #\(rank.rawValue.replacingOccurrences(of: " ", with: ""))
        """

        share(text: text)
    }

    // MARK: - Share Profile Card Image

    @MainActor
    static func shareProfileCardImage(view: some View) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0

        if let image = renderer.uiImage {
            let activityVC = UIActivityViewController(
                activityItems: [image, "My Unlock Egypt journey! #UnlockEgypt"],
                applicationActivities: nil
            )

            presentShareSheet(activityVC)
        }
    }

    // MARK: - Private Helper

    @MainActor
    private static func share(text: String, completion: ShareCompletion? = nil) {
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        presentShareSheet(activityVC, completion: completion)
    }

    @MainActor
    private static func presentShareSheet(_ activityVC: UIActivityViewController, completion: ShareCompletion? = nil) {
        // Clear any previous error
        lastError = nil

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            let error = "Unable to share: No active window found"
            lastError = error
            completion?(false, error)
            return
        }

        guard let rootVC = windowScene.windows.first?.rootViewController else {
            let error = "Unable to share: No root view controller found"
            lastError = error
            completion?(false, error)
            return
        }

        // Find the topmost presented view controller
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        // iPad requires popover configuration
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        // Add completion handler to track success/failure
        activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if let error = error {
                Task { @MainActor in
                    lastError = error.localizedDescription
                    completion?(false, error.localizedDescription)
                }
            } else {
                completion?(completed, nil)
            }
        }

        topVC.present(activityVC, animated: true)
    }
}
