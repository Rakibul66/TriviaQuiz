//
//  TriviaCategory.swift
//  powerquiz
//
//  Created by Roxy  on 6/9/25.
//


import Foundation

// MARK: - Category
struct TriviaCategory: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
}

// counts endpoint response
struct CategoryCountEnvelope: Codable {
    let categoryID: Int
    let categoryQuestionCount: CategoryQuestionCount

    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case categoryQuestionCount = "category_question_count"
    }
}

struct CategoryQuestionCount: Codable {
    let totalQuestionCount: Int
    let totalEasyQuestionCount: Int
    let totalMediumQuestionCount: Int
    let totalHardQuestionCount: Int

    enum CodingKeys: String, CodingKey {
        case totalQuestionCount = "total_question_count"
        case totalEasyQuestionCount = "total_easy_question_count"
        case totalMediumQuestionCount = "total_medium_question_count"
        case totalHardQuestionCount = "total_hard_question_count"
    }
}

// MARK: - Questions
enum Difficulty: String, CaseIterable, Codable, Identifiable {
    case easy, medium, hard
    var id: String { rawValue }
    var emoji: String {
        switch self {
        case .easy: return "🙂"
        case .medium: return "😄"
        case .hard: return "🤓"
        }
    }
}

struct TriviaItem: Identifiable, Codable, Hashable {
    let id = UUID()
    let category: String
    let type: String
    let difficulty: Difficulty
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case category, type, difficulty, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }

    // Randomized options for MCQ UI
    func mixedOptions() -> [String] {
        (incorrectAnswers + [correctAnswer]).shuffled()
    }
}

// envelope from api.php
struct TriviaEnvelope: Codable {
    let responseCode: Int
    let results: [TriviaItem]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}
