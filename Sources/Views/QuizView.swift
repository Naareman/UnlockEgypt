import SwiftUI

struct QuizView: View {
    let quiz: Quiz
    let siteId: String

    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var hasAnswered = false
    @State private var score = 0
    @State private var showResults = false

    private var currentQuestion: QuizQuestion {
        quiz.questions[currentQuestionIndex]
    }

    private var isLastQuestion: Bool {
        currentQuestionIndex == quiz.questions.count - 1
    }

    var body: some View {
        VStack(spacing: 24) {
            if showResults {
                resultsView
            } else {
                questionView
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
    }

    // MARK: - Question View
    private var questionView: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Question \(currentQuestionIndex + 1) of \(quiz.questions.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Score: \(score)")
                        .font(.caption)
                        .fontWeight(.semibold)
                }

                ProgressView(value: Double(currentQuestionIndex + 1), total: Double(quiz.questions.count))
                    .tint(.accentColor)
            }

            // Question
            Text(currentQuestion.question)
                .font(.title3)
                .fontWeight(.semibold)

            // Options
            VStack(spacing: 12) {
                ForEach(0..<currentQuestion.options.count, id: \.self) { index in
                    AnswerButton(
                        text: currentQuestion.options[index],
                        isSelected: selectedAnswer == index,
                        isCorrect: hasAnswered ? index == currentQuestion.correctAnswerIndex : nil,
                        showResult: hasAnswered
                    ) {
                        if !hasAnswered {
                            selectAnswer(index)
                        }
                    }
                }
            }

            // Explanation (shown after answering)
            if hasAnswered {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()

                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: selectedAnswer == currentQuestion.correctAnswerIndex ? "checkmark.circle.fill" : "info.circle.fill")
                            .foregroundColor(selectedAnswer == currentQuestion.correctAnswerIndex ? .green : .blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(selectedAnswer == currentQuestion.correctAnswerIndex ? "Correct!" : "Not quite!")
                                .fontWeight(.semibold)
                            Text(currentQuestion.explanation)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(12)

                    // Fun fact
                    if let funFact = currentQuestion.funFact {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text(funFact)
                                .font(.caption)
                                .italic()
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            // Next button
            if hasAnswered {
                Button(action: nextQuestion) {
                    Text(isLastQuestion ? "See Results" : "Next Question")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
    }

    // MARK: - Results View
    private var resultsView: some View {
        let result = QuizResult(
            quizId: quiz.id,
            siteId: siteId,
            score: score,
            totalQuestions: quiz.questions.count,
            dateTaken: Date()
        )

        return VStack(spacing: 24) {
            // Badge
            Image(systemName: result.badge.icon)
                .font(.system(size: 60))
                .foregroundColor(badgeColor(for: result.badge))

            // Score
            VStack(spacing: 8) {
                Text(result.badge.rawValue)
                    .font(.title)
                    .fontWeight(.bold)

                Text("\(score) out of \(quiz.questions.count) correct")
                    .font(.title3)
                    .foregroundColor(.secondary)

                Text(result.badge.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Score breakdown
            HStack(spacing: 40) {
                ScoreStat(value: "\(Int(result.percentage))%", label: "Score")
                ScoreStat(value: "\(score)", label: "Correct")
                ScoreStat(value: "\(quiz.questions.count - score)", label: "Missed")
            }

            // Retry button
            Button(action: resetQuiz) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Try Again")
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
    }

    // MARK: - Helper Methods
    private func selectAnswer(_ index: Int) {
        selectedAnswer = index
        hasAnswered = true

        if index == currentQuestion.correctAnswerIndex {
            score += 1
        }
    }

    private func nextQuestion() {
        if isLastQuestion {
            withAnimation {
                showResults = true
            }
        } else {
            withAnimation {
                currentQuestionIndex += 1
                selectedAnswer = nil
                hasAnswered = false
            }
        }
    }

    private func resetQuiz() {
        withAnimation {
            currentQuestionIndex = 0
            selectedAnswer = nil
            hasAnswered = false
            score = 0
            showResults = false
        }
    }

    private func badgeColor(for badge: QuizBadge) -> Color {
        switch badge {
        case .perfect: return .yellow
        case .excellent: return .green
        case .good: return .blue
        case .tryAgain: return .orange
        }
    }
}

// MARK: - Answer Button
struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let showResult: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .disabled(showResult)
    }

    private var backgroundColor: Color {
        if showResult {
            if let isCorrect = isCorrect, isCorrect {
                return .green.opacity(0.1)
            } else if isSelected {
                return .red.opacity(0.1)
            }
        }
        return isSelected ? Color.accentColor.opacity(0.1) : Color(uiColor: .systemGray6)
    }

    private var foregroundColor: Color {
        .primary
    }

    private var borderColor: Color {
        if showResult {
            if let isCorrect = isCorrect, isCorrect {
                return .green
            } else if isSelected {
                return .red
            }
        }
        return isSelected ? .accentColor : .clear
    }
}

// MARK: - Score Stat
struct ScoreStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    QuizView(quiz: SampleData.sampleQuiz, siteId: "giza")
}
