# 🧠 Power Quiz

A high-fidelity, modern Trivia experience built with **SwiftUI**. This is a pet project focused on exploring advanced navigation patterns and a "Museum-grade" UI aesthetic.

---



## ✨ Features

- **Dynamic Category Filtering:** Real-time search functionality through dozens of trivia categories.
- **Museum UI Aesthetic:** A clean, minimal design using a secondary system background with high-contrast white cards.
- **Granular Configuration:** Custom steppers for question quantity and tactile difficulty selectors.
- **Haptic Integration:** Uses `UIImpactFeedbackGenerator` to provide physical feedback on digital interactions.
- **Smart Navigation:** Advanced "Pop-to-Root" logic to ensure a seamless transition back to the home screen.

---

## 🛠 Tech Stack

- **Framework:** SwiftUI
- **Architecture:** MVVM (Model-View-ViewModel)
- **Navigation:** `NavigationStack` with centralized `NavigationPath`
- **Data Source:** [OpenTriviaDB API](https://opentdb.com/)
- **State Management:** `@StateObject`, `@Published`, and `@Binding`

---

## 🧠 Technical Deep Dive: Navigation Handling

One of the core challenges in this pet project was managing a deep navigation stack while allowing the user to return to the home screen instantly from the results page.

### The Problem
Standard `dismiss()` calls only pop the current view, requiring multiple steps to return to the root if the user has gone through Setup -> Play -> Results.

### The Solution: NavigationPath Reset
By implementing a centralized `@State var navigationPath = NavigationPath()` in the `ContentView` and passing it as a `@Binding` to child views, I enabled a "Pop-to-Root" feature.



**How it works:**
1. Each screen is appended to the path as an `AppRoute` enum.
2. In the `ResultsView`, instead of dismissing, we call `path = NavigationPath()`.
3. This instantly clears the entire stack and returns the user to the Home screen.

---

## 🚀 Getting Started

1. **Clone the repo:**
   ```bash
   git clone [https://github.com/yourusername/powerquiz.git](https://github.com/yourusername/powerquiz.git)
