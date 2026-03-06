//
//  QuizViewModel.swift
//  powerquiz
//
//  Created by Roxy on 6/9/25.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - HTML decoding used by QuizViewModel
extension String {
    /// Decodes HTML entities coming from OpenTDB (e.g., &quot;, &amp;, &eacute;).
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else { return self }
        #if canImport(UIKit)
        let opts: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributed = try? NSAttributedString(data: data, options: opts, documentAttributes: nil) {
            return attributed.string
        }
        #endif
        return self
    }
}

// MARK: - Safe index helper
extension Array {
    subscript(safe idx: Int) -> Element? {
        guard idx >= 0 && idx < count else { return nil }
        return self[idx]
    }
}

// MARK: - QuizViewModel
@MainActor
final class QuizViewModel: ObservableObject {
    // configuration
    @Published var category: TriviaCategory?
    @Published var difficulty: Difficulty = .medium
    @Published var amount: Int = 20

    // state
    @Published private(set) var questions: [TriviaItem] = []
    @Published private(set) var optionsPerQuestion: [[String]] = []
    @Published var currentIndex: Int = 0
    @Published var selections: [UUID: String] = [:]   // selected option per question
    @Published var loading = false
    @Published var loadError: String?

    var current: TriviaItem? { questions[safe: currentIndex] }

    // MARK: - API
    func startNew() async {
        loadError = nil; loading = true; defer { loading = false }
        do {
            let qs = try await TriviaAPI.fetchQuestions(
                amount: amount,
                categoryID: category?.id,
                difficulty: difficulty
            )

            // decode HTML entities on every text field
            let decoded = qs.map { item in
                TriviaItem(
                    category: item.category.htmlDecoded,
                    type: item.type,
                    difficulty: item.difficulty,
                    question: item.question.htmlDecoded,
                    correctAnswer: item.correctAnswer.htmlDecoded,
                    incorrectAnswers: item.incorrectAnswers.map { $0.htmlDecoded }
                )
            }

            questions = decoded
            optionsPerQuestion = decoded.map { $0.mixedOptions().map { $0.htmlDecoded } }
            currentIndex = 0
            selections = [:]
            persist()
        } catch {
            loadError = "Couldn’t load questions. Try again."
        }
    }

    func select(option: String, for q: TriviaItem) {
        selections[q.id] = option
        persist()
    }

    func next() {
        currentIndex = min(currentIndex + 1, questions.count - 1)
        persist()
    }

    func prev() {
        currentIndex = max(currentIndex - 1, 0)
        persist()
    }

    // MARK: - Scoring & Review
    var correctCount: Int {
        questions.filter { selections[$0.id] == $0.correctAnswer }.count
    }

    var isFinished: Bool {
        selections.count == questions.count
    }

    func answerFor(_ q: TriviaItem) -> String? {
        selections[q.id]
    }

    // MARK: - Persistence
    func persist() {
        let snap = QuizSession(
            categoryID: category?.id,
            difficulty: difficulty,
            amount: amount,
            questions: questions,
            currentIndex: currentIndex,
            selections: selections
        )
        QuizStorage.save(snap)
    }

    func restoreIfAvailable() {
        guard let s = QuizStorage.load() else { return }
        amount = s.amount
        difficulty = s.difficulty ?? .medium
        questions = s.questions
        optionsPerQuestion = s.questions.map { $0.mixedOptions() }
        currentIndex = s.currentIndex
        selections = s.selections
    }

    func clearSaved() {
        QuizStorage.clear()
    }
}
