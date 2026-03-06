import SwiftUI

struct SetupQuizView: View {
    @ObservedObject var vm: QuizViewModel
    let category: TriviaCategory
    
    // THE FIX: This binding allows this view to control the navigation stack
    @Binding var path: NavigationPath
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Background color for a clean "Museum" look
            Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
            
            VStack(spacing: 25) {
                // 1. HEADER SECTION
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.system(.title, design: .rounded).bold())
                        Text("Configure your challenge")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // 2. QUESTION QUANTITY CARD
                        QuantitySelectorCard(amount: $vm.amount)

                        // 3. DIFFICULTY SELECTION
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Difficulty Level")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                ForEach(Difficulty.allCases) { diff in
                                    DifficultyButton(
                                        diff: diff,
                                        isSelected: vm.difficulty == diff,
                                        action: {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            vm.difficulty = diff
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }

                        // 4. INFO BOX
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Quick Info", systemImage: "info.circle")
                                .font(.caption.bold())
                                .foregroundColor(.blue)
                            
                            Text("This quiz will consist of \(vm.amount) questions. You'll earn points based on speed and accuracy.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                }

                // 5. START BUTTON
                PlayButton(isLoading: vm.loading) {
                    Task {
                        vm.category = category
                        await vm.startNew()
                        
                        // If data is fetched, push the Play view onto the stack
                        if !vm.questions.isEmpty {
                            path.append(AppRoute.play)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Connection Error", isPresented: Binding(
            get: { vm.loadError != nil },
            set: { _ in vm.loadError = nil })) {
                Button("Got it", role: .cancel) {}
            } message: { Text(vm.loadError ?? "") }
    }
}

// MARK: - SUPPORTING UI COMPONENTS

struct QuantitySelectorCard: View {
    @Binding var amount: Int
    
    var body: some View {
        VStack(spacing: 15) {
            Text("NUMBER OF QUESTIONS")
                .font(.caption.bold())
                .foregroundColor(.secondary)
            
            HStack(spacing: 40) {
                StepperButton(icon: "minus") { if amount > 5 { amount -= 5 } }
                
                Text("\(amount)")
                    .font(.system(size: 60, weight: .heavy, design: .rounded))
                    .frame(width: 80)
                
                StepperButton(icon: "plus") { if amount < 50 { amount += 5 } }
            }
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        .padding(.horizontal)
    }
}

struct DifficultyButton: View {
    let diff: Difficulty
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(diff.emoji)
                    .font(.title)
                Text(diff.rawValue.capitalized)
                    .font(.caption.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(isSelected ? Color.blue : Color.white)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.black.opacity(0.05), radius: 8, y: 4)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

struct StepperButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2.bold())
                .foregroundColor(.blue)
                .frame(width: 50, height: 50)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
        }
    }
}

struct PlayButton: View {
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("START CHALLENGE")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
            .foregroundColor(.white)
            .cornerRadius(18)
            .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
        }
        .disabled(isLoading)
    }
}
