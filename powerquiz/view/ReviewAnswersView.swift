//
//  ReviewAnswersView.swift
//  powerquiz
//
//  Created by Roxy  on 6/9/25.
//


import SwiftUI

struct ReviewAnswersView: View {
    @ObservedObject var vm: QuizViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(vm.questions.enumerated()), id: \.1.id) { (index, q) in
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(q.question).font(.headline)
                            if let yours = vm.answerFor(q) {
                                LabeledContent("Your answer") { Text(yours) }
                                    .foregroundStyle(yours == q.correctAnswer ? .green : .red)
                            } else {
                                Text("You skipped this question").foregroundStyle(.secondary)
                            }
                            LabeledContent("Correct answer") { Text(q.correctAnswer) }
                                .foregroundStyle(.green)
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("Question \(index + 1)")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Review answers")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
}
