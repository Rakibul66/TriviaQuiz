import SwiftUI



import SwiftUI

enum AppRoute: Hashable {
    case setup(TriviaCategory)
    case play
    case results
}
struct ContentView: View {
    @StateObject private var categoriesVM = CategoryViewModel()
    @StateObject private var quizVM = QuizViewModel()
    
    @State private var navigationPath = NavigationPath()
    @State private var searchText = ""
    @State private var hasResume = false

    var filteredCategories: [TriviaCategory] {
        searchText.isEmpty ? categoriesVM.categories :
        categoriesVM.categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .top) {
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()

                VStack(spacing: 12) {
                    QuizHeroCard()
                        .padding(.top, 10)

                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                    
                    if hasResume {
                        Button(action: {
                            quizVM.restoreIfAvailable()
                            navigationPath.append(AppRoute.play)
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "clock.arrow.circlepath").font(.headline)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Resume your last quiz")
                                        .font(.subheadline.bold())
                                    Text("Pick up where you left off")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption.bold()).foregroundColor(.secondary)
                            }
                            .padding(14)
                            .background(Color.white)
                            .cornerRadius(14)
                            .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
                            .padding(.horizontal)
                        }
                    }

                    // Scroll only the categories list
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            if categoriesVM.categories.isEmpty {
                                VStack(spacing: 10) {
                                    ProgressView()
                                    Text("Fetching categories...")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(Color.white)
                                .cornerRadius(16)
                                .padding(.horizontal)
                            }

                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                                ForEach(filteredCategories) { cat in
                                    CategoryTile(category: cat) {
                                        navigationPath.append(AppRoute.setup(cat))
                                    }
                                    .transition(.opacity.combined(with: .scale))
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                        }
                    }
                    .refreshable { await categoriesVM.load() }
                }
            }
            .navigationTitle("Quiz Master")
            .navigationBarTitleDisplayMode(.inline)
            // THE CENTRAL ROUTER
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .setup(let cat):
                    SetupQuizView(vm: quizVM, category: cat, path: $navigationPath)
                case .play:
                    QuizPlayView(vm: quizVM, path: $navigationPath)
                case .results:
                    ResultsView(vm: quizVM, path: $navigationPath)
                }
            }
            .task {
                await categoriesVM.load()
                // Evaluate resume availability without altering current session state
                let hadSaved = QuizStorage.load() != nil
                hasResume = hadSaved
            }
        }
    }
}
