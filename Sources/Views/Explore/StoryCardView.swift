import SwiftUI

// MARK: - Story Cards Flow View
struct StoryCardsView: View {
    let subLocation: SubLocation
    @State private var currentIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showingAnswer = false
    @State private var sessionPoints = 0
    @State private var showCompletion = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: HomeViewModel

    var body: some View {
        ZStack {
            // Dark gradient background
            LinearGradient(
                colors: [Theme.Colors.darkBackground, Theme.Colors.darkBackgroundDeep],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if showCompletion {
                completionView
            } else {
                VStack(spacing: 0) {
                    // Header
                    storyHeader
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // Progress bar
                    progressBar
                        .padding(.horizontal)
                        .padding(.top, 12)

                    // Card content
                    TabView(selection: $currentIndex) {
                        ForEach(Array(subLocation.storyCards.enumerated()), id: \.element.id) { index, card in
                            SingleCardView(
                                card: card,
                                selectedAnswer: currentIndex == index ? $selectedAnswer : .constant(nil),
                                showingAnswer: currentIndex == index ? $showingAnswer : .constant(false),
                                onCorrectAnswer: {
                                    if let quiz = card.quizQuestion {
                                        viewModel.correctQuizAnswer(quiz.id)
                                        sessionPoints += 10
                                    }
                                },
                                onNext: { goToNext() }
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    // Navigation
                    navigationBar
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            // Award discovery point when starting
            viewModel.discoverPlace(subLocation.id)
            sessionPoints += 1
        }
    }

    // MARK: - Story Header
    private var storyHeader: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            VStack(spacing: 2) {
                Text(subLocation.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(currentIndex + 1) of \(subLocation.storyCards.count)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            // Points earned this session
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(Theme.Colors.gold)
                Text("+\(sessionPoints)")
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.gold)
            }
            .font(.caption)
        }
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 4)

                // Progress
                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.Colors.gold)
                    .frame(width: geo.size.width * CGFloat(currentIndex + 1) / CGFloat(subLocation.storyCards.count), height: 4)
                    .animation(.easeInOut, value: currentIndex)
            }
        }
        .frame(height: 4)
    }

    // MARK: - Navigation Bar
    private var navigationBar: some View {
        HStack {
            // Back button
            Button(action: goToPrevious) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(currentIndex > 0 ? .white : .clear)
            }
            .disabled(currentIndex == 0)

            Spacer()

            // Next/Finish button
            Button(action: {
                if currentIndex == subLocation.storyCards.count - 1 {
                    // Show completion screen
                    withAnimation {
                        showCompletion = true
                    }
                    viewModel.completeSubLocation(subLocation.id)
                } else {
                    goToNext()
                }
            }) {
                HStack {
                    Text(currentIndex == subLocation.storyCards.count - 1 ? "Finish" : "Next")
                    Image(systemName: currentIndex == subLocation.storyCards.count - 1 ? "checkmark" : "chevron.right")
                }
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Theme.Colors.gold)
                .cornerRadius(25)
            }
        }
    }

    // MARK: - Completion View
    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Success icon
            ZStack {
                Circle()
                    .fill(Theme.Colors.gold.opacity(0.2))
                    .frame(width: 120, height: 120)
                Circle()
                    .fill(Theme.Colors.gold.opacity(0.3))
                    .frame(width: 100, height: 100)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Theme.Colors.gold)
            }

            VStack(spacing: 8) {
                Text("🎉 Congratulations!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("You explored \(subLocation.name)")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }

            // Points summary
            VStack(spacing: 16) {
                HStack {
                    Text("Points earned")
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text("+\(sessionPoints) pts")
                        .fontWeight(.bold)
                        .foregroundColor(Theme.Colors.gold)
                }

                Divider()
                    .background(Color.white.opacity(0.2))

                HStack {
                    Text("Total points")
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text("\(viewModel.totalPoints) pts")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .padding(.horizontal, 32)

            Spacer()

            // Done button
            Button(action: { dismiss() }) {
                Text("Done")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.Colors.gold)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }

    private func goToNext() {
        if currentIndex < subLocation.storyCards.count - 1 {
            withAnimation {
                selectedAnswer = nil
                showingAnswer = false
                currentIndex += 1
            }
        }
    }

    private func goToPrevious() {
        if currentIndex > 0 {
            withAnimation {
                selectedAnswer = nil
                showingAnswer = false
                currentIndex -= 1
            }
        }
    }
}

// MARK: - Single Card View
struct SingleCardView: View {
    let card: StoryCard
    @Binding var selectedAnswer: Int?
    @Binding var showingAnswer: Bool
    let onCorrectAnswer: () -> Void
    let onNext: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Image area
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(
                            colors: [Theme.Colors.gold.opacity(0.2), Theme.Colors.sand.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 220)

                    // Placeholder image based on card type
                    VStack(spacing: 12) {
                        Image(systemName: cardIcon)
                            .font(.system(size: 50))
                            .foregroundColor(Theme.Colors.gold.opacity(0.6))
                        Text(cardTypeLabel)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.Colors.gold.opacity(0.8))
                    }
                }
                .padding(.horizontal)

                // Content based on type
                switch card.type {
                case .intro:
                    introContent
                case .story:
                    storyContent
                case .fact:
                    factContent
                case .quiz:
                    quizContent
                case .summary:
                    summaryContent
                }

                Spacer(minLength: 100)
            }
            .padding(.top, 20)
        }
    }

    // MARK: - Card Type Helpers
    private var cardIcon: String {
        switch card.type {
        case .intro: return "play.circle.fill"
        case .story: return "book.fill"
        case .fact: return "lightbulb.fill"
        case .quiz: return "questionmark.circle.fill"
        case .summary: return "checkmark.seal.fill"
        }
    }

    private var cardTypeLabel: String {
        switch card.type {
        case .intro: return "INTRODUCTION"
        case .story: return "THE STORY"
        case .fact: return "FUN FACT"
        case .quiz: return "QUIZ TIME"
        case .summary: return "SUMMARY"
        }
    }

    // MARK: - Intro Content
    private var introContent: some View {
        VStack(spacing: 16) {
            Text("Let's Begin")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Theme.Colors.gold)
                .tracking(2)

            if let content = card.content {
                Text(content)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Story Content
    private var storyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let content = card.content {
                Text(content)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(8)
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Fact Content
    private var factContent: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title)
                    .foregroundColor(Theme.Colors.gold)
                Text("DID YOU KNOW?")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.gold)
                    .tracking(2)
            }

            if let fact = card.funFact {
                Text(fact)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
        }
        .padding(24)
        .background(Theme.Colors.gold.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Theme.Colors.gold.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }

    // MARK: - Quiz Content
    private var quizContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(Theme.Colors.quizBlue)
                Text("QUICK QUIZ")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.quizBlue)
                    .tracking(2)
            }

            if let question = card.quizQuestion {
                Text(question.question)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    ForEach(0..<question.options.count, id: \.self) { index in
                        QuizOptionButton(
                            text: question.options[index],
                            isSelected: selectedAnswer == index,
                            isCorrect: showingAnswer ? index == question.correctAnswerIndex : nil,
                            showResult: showingAnswer
                        ) {
                            if !showingAnswer {
                                selectedAnswer = index
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showingAnswer = true
                                }
                                if index == question.correctAnswerIndex {
                                    onCorrectAnswer()
                                }
                            }
                        }
                    }
                }

                if showingAnswer {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: selectedAnswer == question.correctAnswerIndex ? "checkmark.circle.fill" : "info.circle.fill")
                                .foregroundColor(selectedAnswer == question.correctAnswerIndex ? .green : .orange)
                            Text(selectedAnswer == question.correctAnswerIndex ? "Correct! +10 pts" : "Not quite!")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }

                        Text(question.explanation)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .padding(24)
        .background(Theme.Colors.quizBlue.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Theme.Colors.quizBlue.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }

    // MARK: - Summary Content
    private var summaryContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 50))
                .foregroundColor(Theme.Colors.gold)

            Text("Story Complete!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            if let content = card.content {
                Text(content)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Quiz Option Button
struct QuizOptionButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let showResult: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                Spacer()
                if showResult {
                    if let isCorrect = isCorrect, isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 0)
            )
        }
        .disabled(showResult)
    }

    private var backgroundColor: Color {
        if showResult {
            if let isCorrect = isCorrect, isCorrect {
                return .green.opacity(0.2)
            } else if isSelected {
                return .red.opacity(0.2)
            }
        }
        return Color.white.opacity(0.1)
    }

    private var borderColor: Color {
        if showResult {
            if let isCorrect = isCorrect, isCorrect {
                return .green
            } else if isSelected {
                return .red
            }
        }
        return isSelected ? Theme.Colors.quizBlue : .clear
    }
}

#Preview {
    StoryCardsView(subLocation: SubLocation(
        id: "test",
        name: "Great Pyramid",
        arabicName: "الهرم الأكبر",
        shortDescription: "Test",
        imageName: nil,
        storyCards: [
            StoryCard(id: "1", type: .intro, imageName: nil, content: "Welcome to the Great Pyramid!", funFact: nil, quizQuestion: nil),
            StoryCard(id: "2", type: .fact, imageName: nil, content: nil, funFact: "It was the tallest structure for 3,800 years!", quizQuestion: nil)
        ]
    ))
    .environmentObject(HomeViewModel())
}
