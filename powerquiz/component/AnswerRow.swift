//
//  AnswerRow.swift
//  powerquiz
//
//  Created by Roxy  on 6/9/25.
//


import SwiftUI

struct AnswerRow: View {
    enum State { case neutral, correct, wrong, correctGhost }

    let text: String
    let state: State
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(foreground)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(background, in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(border, lineWidth: state == .neutral ? 1 : 0)
            )
        }
        .buttonStyle(.plain)
        .disabled(state == .correct || state == .wrong) // prevent reselection after pick
    }

    private var background: Color {
        switch state {
        case .neutral: return .secondary.opacity(0.08)
        case .correct: return .green.opacity(0.25)
        case .wrong: return .red.opacity(0.20)
        case .correctGhost: return .green.opacity(0.12)
        }
    }
    private var border: Color { .secondary.opacity(0.25) }
    private var foreground: Color { state == .neutral ? .primary : .primary }
}
