import SwiftUI

// MARK: - Story Cards Flow View
/// Displays story cards in a swipeable/tappable flow
struct StoryCardsView: View {
    let subLocation: SubLocation
    @State private var currentIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showingAnswer = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                progressBar
                    .padding(.horizontal)
                    .padding(.top, 8)

                // Card content
                TabView(selection: $currentIndex) {
                    ForEach(Array(subLocation.storyCards.enumerated()), id: \.element.id) { index, card in
                        SingleCardView(
                            card: card,
                            selectedAnswer: currentIndex == index ? $selectedAnswer : .constant(nil),
                            showingAnswer: currentIndex == index ? $showingAnswer : .constant(false),
                            onNext: { goToNext() }
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Navigation hints
                navigationHints
                    .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.white)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(0..<subLocation.storyCards.count, id: \.self) { index in
                Capsule()
                    .fill(index <= currentIndex ? Color.white : Color.white.opacity(0.3))
                    .frame(height: 3)
            }
        }
    }

    // MARK: - Navigation Hints
    private var navigationHints: some View {
        HStack {
            if currentIndex > 0 {
                Button(action: goToPrevious) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }

            Spacer()

            if currentIndex < subLocation.storyCards.count - 1 {
                Button(action: goToNext) {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.white)
                }
            } else {
                Button(action: { dismiss() }) {
                    HStack {
                        Text("Finish")
                        Image(systemName: "checkmark")
                    }
                    .foregroundColor(.green)
                }
            }
        }
        .padding(.horizontal, 24)
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
    let onNext: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image placeholder
                if card.imageName != nil {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(
                            colors: [.orange.opacity(0.6), .brown.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: cardIcon)
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.5))
                        )
                        .padding(.horizontal)
                }

                // Card content based on type
                switch card.type {
                case .intro, .story, .summary:
                    storyContent

                case .fact:
                    factContent

                case .quiz:
                    quizContent
                }

                Spacer(minLength: 100)
            }
            .padding(.top, 20)
        }
    }

    // MARK: - Story Content
    private var storyContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let content = card.content {
                Text(content)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineSpacing(6)
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Fact Content ("Did you know?")
    private var factContent: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
                Text("Did you know?")
                    .font(.headline)
                    .foregroundColor(.yellow)
            }

            if let fact = card.funFact {
                Text(fact)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
        }
        .padding(24)
        .background(Color.yellow.opacity(0.15))
        .cornerRadius(16)
        .padding(.horizontal, 24)
    }

    // MARK: - Quiz Content
    private var quizContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Question header
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Quick Quiz")
                    .font(.headline)
                    .foregroundColor(.blue)
            }

            if let question = card.quizQuestion {
                Text(question.question)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                // Options
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
                            }
                        }
                    }
                }

                // Explanation
                if showingAnswer {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: selectedAnswer == question.correctAnswerIndex ? "checkmark.circle.fill" : "info.circle.fill")
                                .foregroundColor(selectedAnswer == question.correctAnswerIndex ? .green : .orange)
                            Text(selectedAnswer == question.correctAnswerIndex ? "Correct!" : "Not quite!")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }

                        Text(question.explanation)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .padding(24)
        .background(Color.blue.opacity(0.15))
        .cornerRadius(16)
        .padding(.horizontal, 24)
    }

    private var cardIcon: String {
        switch card.type {
        case .intro: return "play.circle"
        case .story: return "book"
        case .fact: return "lightbulb"
        case .quiz: return "questionmark.circle"
        case .summary: return "checkmark.circle"
        }
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
                return .green.opacity(0.3)
            } else if isSelected {
                return .red.opacity(0.3)
            }
        }
        return .white.opacity(0.1)
    }

    private var borderColor: Color {
        if showResult {
            if let isCorrect = isCorrect, isCorrect {
                return .green
            } else if isSelected {
                return .red
            }
        }
        return isSelected ? .white : .clear
    }
}

#Preview {
    NavigationStack {
        StoryCardsView(subLocation: SubLocation(
            id: "great_pyramid",
            name: "The Great Pyramid",
            arabicName: "الهرم الأكبر",
            shortDescription: "The tomb of Pharaoh Khufu",
            imageName: "great_pyramid",
            storyCards: [
                StoryCard(id: "1", type: .intro, imageName: "pyramid", content: "Welcome to the Great Pyramid of Giza, the last surviving wonder of the ancient world.", funFact: nil, quizQuestion: nil),
                StoryCard(id: "2", type: .story, imageName: "pyramid2", content: "Built around 2560 BCE for Pharaoh Khufu, this massive structure took about 20 years to complete.", funFact: nil, quizQuestion: nil),
                StoryCard(id: "3", type: .fact, imageName: nil, content: nil, funFact: "The Great Pyramid was the tallest man-made structure in the world for over 3,800 years!", quizQuestion: nil)
            ]
        ))
    }
}
