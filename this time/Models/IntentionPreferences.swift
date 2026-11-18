import Foundation

struct AlternativeActivity: Codable, Identifiable, Equatable {
    var id = UUID()
    var text: String
}

struct IntentionPreferences: Codable {
    var onboardingComplete = false
    var alternatives: [AlternativeActivity] = []
}

struct IntentionPrompt: Equatable {
    let text: String

    static func make(service: Service, history: [SessionHistoryEntry], alternatives: [AlternativeActivity], now: Date = Date()) -> Self {
        let subject = service.webDomainTokenData != nil ? "this website"
            : service.categoryTokenData != nil ? "this category" : "this app"
        var prompts = [
            "Why do you want to open \(subject) this time?",
            "What are you opening \(subject) for?",
            "What’s the plan for \(subject)?"
        ]
        if let previous = history.first(where: {
            $0.service.id == service.id && Calendar.current.isDate($0.startedAt, inSameDayAs: now)
        }) {
            prompts.append("Earlier you wrote: “\(previous.intention)”\nSo, what is it this time?")
        }
//        if let alternative = alternatives.randomElement() {
//            prompts.append("You listed “\(alternative.text)” as another option. What’s the plan this time?")
//            prompts.append("Open \(subject), or “\(alternative.text)”? What are you going with?")
//        }
        var text = prompts.randomElement() ?? prompts[0]
        // Pick once per request so typing never changes the copy. Most prompts stay plain.
        if Int.random(in: 0..<5) == 0 {
            let asides = [
                "You are being judged for this.",
                "Remember, his life is in your hands.",
                "Answer dishonestly and die.",
            ]
            if let aside = asides.randomElement() { text += "\n\n" + aside }
        }
        return Self(text: text)
    }
}
