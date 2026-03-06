import SwiftUI

struct ResultsView: View {
    @ObservedObject var vm: QuizViewModel
    @Binding var path: NavigationPath // Linked to ContentView
    @State private var showReview = false

    private var scorePercentage: Double {
        let total = Double(max(vm.questions.count, 1))
        let correct = Double(vm.correctCount)
        return (correct / total)
    }

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Visual Score Gauge
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.1), lineWidth: 20)
                Circle()
                    .trim(from: 0, to: scorePercentage)
                    .stroke(LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(Int(scorePercentage * 100))%")
                        .font(.system(size: 50, weight: .heavy, design: .rounded))
                    Text("SCORE")
                        .font(.caption.bold()).foregroundColor(.secondary)
                }
            }
            .frame(width: 180, height: 180)

            Text(scorePercentage > 0.6 ? "Great Job!" : "Keep Practicing!")
                .font(.title2.bold())

            // Detailed Stats
            HStack(spacing: 15) {
                ResultStatCard(title: "Correct", value: "\(vm.correctCount)", color: .green)
                ResultStatCard(title: "Wrong", value: "\(vm.questions.count - vm.correctCount)", color: .red)
            }
            .padding(.horizontal)

            Spacer()

            // Navigation Buttons
            VStack(spacing: 14) {
                Button("Review My Answers") {
                    showReview = true
                }
                .font(.headline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)

                // THE FIX: Resetting the path goes straight to Home
                Button(action: {
                    vm.clearSaved()
                    path = NavigationPath() // This clears the entire stack
                }) {
                    Text("Back to Home")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                        .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .navigationBarBackButtonHidden(true) // Disable swiping back
        .sheet(isPresented: $showReview) {
            ReviewAnswersView(vm: vm)
        }
    }
}

struct ResultStatCard: View {
    let title: String
    let value: String
    let color: Color
    var body: some View {
        VStack {
            Text(value).font(.title.bold()).foregroundColor(color)
            Text(title).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}
