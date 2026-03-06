//
//  CategoryViewModel.swift
//  powerquiz
//
//  Created by Roxy  on 6/9/25.
//


import Foundation

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published var categories: [TriviaCategory] = []
    @Published var counts: [Int: Int] = [:]           // total per category
    @Published var isLoading = false
    @Published var error: String?

    func load() async {
        guard !isLoading else { return }
        isLoading = true; defer { isLoading = false }
        do {
            let cats = try await TriviaAPI.fetchCategories()
            categories = cats
            // lazy fetch counts without blocking UI
            for cat in cats {
                Task.detached { [weak self] in
                    if let q = try? await TriviaAPI.fetchCount(for: cat.id) {
                        await MainActor.run { self?.counts[cat.id] = q.totalQuestionCount }
                    }
                }
            }
        } catch {
            self.error = "Failed to load categories."
        }
    }

    func countText(for id: Int) -> String {
        if let c = counts[id] { return "count \(c)" }
        return "loading…"
    }
}
