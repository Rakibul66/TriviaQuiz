//
//  TriviaAPIError.swift
//  powerquiz
//
//  Created by Roxy  on 6/9/25.
//


import Foundation

enum TriviaAPIError: Error {
    case badStatus(Int), empty, decode, server, invalidURL
}

struct TriviaAPI {
    private static let base = "https://opentdb.com"

    // categories list
    static func fetchCategories() async throws -> [TriviaCategory] {
        let url = URL(string: "\(base)/api_category.php")!
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else { throw TriviaAPIError.server }
        struct Wrap: Codable { let trivia_categories: [TriviaCategory] }
        return try JSONDecoder().decode(Wrap.self, from: data).trivia_categories
    }

    // category counts (used to show “count 365” etc). You can call lazily per cell.
    static func fetchCount(for categoryID: Int) async throws -> CategoryQuestionCount {
        let url = URL(string: "\(base)/api_count.php?category=\(categoryID)")!
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else { throw TriviaAPIError.server }
        return try JSONDecoder().decode(CategoryCountEnvelope.self, from: data).categoryQuestionCount
    }

    // questions
    static func fetchQuestions(amount: Int,
                               categoryID: Int?,
                               difficulty: Difficulty?) async throws -> [TriviaItem] {
        var comps = URLComponents(string: "\(base)/api.php")!
        var items = [URLQueryItem(name: "amount", value: String(amount)),
                     URLQueryItem(name: "type", value: "multiple")] // stick to MCQ
        if let categoryID { items.append(URLQueryItem(name: "category", value: String(categoryID))) }
        if let difficulty { items.append(URLQueryItem(name: "difficulty", value: difficulty.rawValue)) }
        comps.queryItems = items

        guard let url = comps.url else { throw TriviaAPIError.invalidURL }
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else { throw TriviaAPIError.server }
        let env = try JSONDecoder().decode(TriviaEnvelope.self, from: data)
        if env.responseCode != 0 { throw TriviaAPIError.empty }
        return env.results
    }
}
