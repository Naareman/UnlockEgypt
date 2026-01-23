import SwiftUI
import UIKit

/// Service for sharing content from the app
struct ShareService {

    // MARK: - Share Site

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

    static func shareKnowledgeKey(for subLocation: SubLocation, siteName: String) {
        let text = """
        🗝️ Knowledge Key Unlocked!

        I've unlocked the secrets of \(subLocation.name) at \(siteName)!

        \(subLocation.shortDescription)

        Discover Egypt's mysteries with Unlock Egypt!

        #UnlockEgypt #AncientSecrets
        """

        share(text: text)
    }

    // MARK: - Share Profile Card

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

    private static func share(text: String) {
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        presentShareSheet(activityVC)
    }

    private static func presentShareSheet(_ activityVC: UIActivityViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
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

        topVC.present(activityVC, animated: true)
    }
}
