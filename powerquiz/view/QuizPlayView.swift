//
//  QuizPlayView.swift
//  powerquiz
//
//  Created by Roxy  on 6/9/25.
//


import SwiftUI

struct QuizPlayView: View {
    @ObservedObject var vm: QuizViewModel
    @Binding var path: NavigationPath

    @State private var showReview = false

    var body: some View {
        VStack(spacing: 16) {
            // progress & header
            HStack {
                Button(action: vm.prev) {
                    Image(systemName: "chevron.left")
                }.disabled(vm.currentIndex == 0)

                Spacer()

                Text("Question \(vm.currentIndex + 1) of \(vm.questions.count)")
                    .font(.headline)

                Spacer()

                Button(action: vm.next) {
                    Image(systemName: "chevron.right")
                }.disabled(vm.currentIndex == vm.questions.count - 1)
            }
            .padding(.horizontal)

            ProgressDots(current: vm.currentIndex, total: vm.questions.count)

            Divider().opacity(0.3)

            // question
            if let q = vm.current {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(q.question)
                            .font(.title3.weight(.semibold))
                            .padding(.horizontal)

                        ForEach(vm.optionsPerQuestion[vm.currentIndex], id: \.self) { option in
                            AnswerRow(
                                text: option,
                                state: stateFor(q: q, option: option)
                            ) {
                                vm.select(option: option, for: q)
                                // auto-advance if last choice selected? optional
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
            }

            Spacer()

            // footer buttons
            HStack(spacing: 12) {
                Button("Review") { showReview = true }
                    .buttonStyle(.bordered)

                Spacer()

                Button(vm.isFinished ? "Finish" : "Next") {
                    if vm.isFinished {
                        path.append(AppRoute.results)
                    } else {
                        vm.next()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showReview) {
            ReviewAnswersView(vm: vm)
                .presentationDetents([.large])
        }
    }

    // show selection/correctness like your screenshot
    private func stateFor(q: TriviaItem, option: String) -> AnswerRow.State {
        let selected = vm.answerFor(q)
        if let selected {
            if option == selected && option == q.correctAnswer { return .correct }
            if option == selected && option != q.correctAnswer { return .wrong }
            if option == q.correctAnswer { return .correctGhost } // reveal correct
        }
        return .neutral
    }
}

struct ProgressDots: View {
    let current: Int
    let total: Int
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { i in
                Circle()
                    .fill(i == current ? Color.green : .red.opacity(0.6))
                    .frame(width: 10, height: 10)
            }
        }
    }
}
