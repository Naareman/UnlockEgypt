import SwiftUI
import AVFoundation

struct SiteDetailView: View {
    let site: Site
    @State private var selectedTab: DetailTab = .story
    @State private var isPlayingAudio = false
    @StateObject private var audioPlayer = AudioPlayerManager()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Image
                heroSection

                // Content
                VStack(spacing: 20) {
                    // Site info header
                    siteHeader

                    // Tab selector
                    detailTabSelector

                    // Tab content
                    switch selectedTab {
                    case .story:
                        storyContent
                    case .quiz:
                        quizContent
                    case .info:
                        infoContent
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Placeholder gradient (replace with actual image)
            LinearGradient(
                colors: [.orange, .brown.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 280)

            // Gradient overlay for text readability
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Era badge
            VStack(alignment: .leading) {
                Spacer()
                Text(site.era.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
            }
            .padding()
        }
        .frame(height: 280)
    }

    // MARK: - Site Header
    private var siteHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(site.name)
                .font(.title)
                .fontWeight(.bold)

            Text(site.arabicName)
                .font(.title3)
                .foregroundColor(.secondary)

            Text(site.shortDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.top, 4)

            // Audio button if available
            if let firstStory = site.stories.first, firstStory.audioFileName != nil {
                Button(action: { toggleAudio() }) {
                    HStack {
                        Image(systemName: isPlayingAudio ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title2)
                        Text(isPlayingAudio ? "Pause Narration" : "Listen to Story")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.accentColor)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Tab Selector
    private var detailTabSelector: some View {
        HStack(spacing: 0) {
            ForEach(DetailTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: tab.icon)
                            Text(tab.title)
                        }
                        .fontWeight(selectedTab == tab ? .semibold : .regular)
                        .foregroundColor(selectedTab == tab ? .accentColor : .secondary)

                        Rectangle()
                            .fill(selectedTab == tab ? Color.accentColor : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Story Content
    private var storyContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(site.stories) { story in
                StoryCard(story: story)
            }
        }
    }

    // MARK: - Quiz Content
    private var quizContent: some View {
        Group {
            if let quiz = site.quiz {
                QuizView(quiz: quiz, siteId: site.id)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "questionmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Quiz coming soon!")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
    }

    // MARK: - Info Content
    private var infoContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Visit Info
            InfoSection(title: "Plan Your Visit", icon: "clock") {
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(label: "Duration", value: site.visitInfo.estimatedDuration)
                    InfoRow(label: "Best Time", value: site.visitInfo.bestTimeToVisit)
                }
            }

            // Tips
            InfoSection(title: "Tips", icon: "lightbulb") {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(site.visitInfo.tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text(tip)
                                .font(.subheadline)
                        }
                    }
                }
            }

            // Arabic Phrases
            InfoSection(title: "Useful Arabic Phrases", icon: "text.bubble") {
                VStack(spacing: 12) {
                    ForEach(site.visitInfo.arabicPhrases) { phrase in
                        PhraseRow(phrase: phrase)
                    }
                }
            }
        }
    }

    private func toggleAudio() {
        isPlayingAudio.toggle()
        // Audio implementation will go here
    }
}

// MARK: - Detail Tab
enum DetailTab: CaseIterable {
    case story, quiz, info

    var title: String {
        switch self {
        case .story: return "Story"
        case .quiz: return "Quiz"
        case .info: return "Visit Info"
        }
    }

    var icon: String {
        switch self {
        case .story: return "book"
        case .quiz: return "questionmark.circle"
        case .info: return "info.circle"
        }
    }
}

// MARK: - Story Card
struct StoryCard: View {
    let story: Story
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(story.title)
                        .font(.headline)
                    HStack(spacing: 8) {
                        Label(story.perspective.rawValue, systemImage: story.perspective.icon)
                        Text("·")
                        Text("\(story.estimatedReadTime) min read")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.secondary)
            }

            if isExpanded {
                Divider()

                // Chapters
                ForEach(story.chapters) { chapter in
                    ChapterView(chapter: chapter)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded.toggle()
            }
        }
    }
}

// MARK: - Chapter View
struct ChapterView: View {
    let chapter: Chapter

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(chapter.title)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(chapter.content)
                .font(.body)
                .lineSpacing(4)

            if let didYouKnow = chapter.didYouKnow {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text("Did you know? \(didYouKnow)")
                        .font(.caption)
                        .italic()
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Info Section
struct InfoSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.headline)
            }
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

// MARK: - Phrase Row
struct PhraseRow: View {
    let phrase: ArabicPhrase

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(phrase.english)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(phrase.arabic)
                .font(.title3)
            Text(phrase.pronunciation)
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Audio Player Manager
class AudioPlayerManager: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false

    func play(fileName: String) {
        // Implementation for playing audio files
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }

    func stop() {
        audioPlayer?.stop()
        isPlaying = false
    }
}

#Preview {
    NavigationStack {
        SiteDetailView(site: SampleData.sites[0])
    }
}
