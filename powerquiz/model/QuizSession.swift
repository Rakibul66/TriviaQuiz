//
//  QuizSession.swift
//  powerquiz
//
//  Created by Roxy  on 6/9/25.
//


import Foundation

struct QuizSession: Codable {
    let categoryID: Int?
    let difficulty: Difficulty?
    let amount: Int
    let questions: [TriviaItem]
    var currentIndex: Int
    var selections: [UUID: String] // question.id -> chosen answer
}

enum QuizStorage {
    private static let key = "quiz.session.v1"

    static func load() -> QuizSession? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(QuizSession.self, from: data)
    }

    static func save(_ session: QuizSession) {
        if let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
