import SwiftUI
import NaturalLanguage
import Observation

@MainActor
@Observable
class DebriefViewModel {
    var feedbackText: String = ""
    var backgroundColor: Color = .white
    
    func analyzeSentiment(for recipe: RecipeModel, onComplete: @escaping () -> Void) async {
        let textToAnalyze = feedbackText
        
        let emoji = await Task.detached(priority: .userInitiated) { () -> String in
            let tagger = NLTagger(tagSchemes: [.sentimentScore])
            tagger.string = textToAnalyze
            
            let (sentiment, _) = tagger.tag(at: textToAnalyze.startIndex, unit: .paragraph, scheme: .sentimentScore)
            let score = Double(sentiment?.rawValue ?? "0") ?? 0
            
            if score > 0.5 { return "🤩" }
            else if score > 0 { return "😊" }
            else if score > -0.5 { return "😐" }
            else { return "😢" }
        }.value
        
        recipe.userFeedback = textToAnalyze
        recipe.emojiMood = emoji
        
        withAnimation {
            backgroundColor = (emoji == "🤩" || emoji == "😊") ? Pal.cGold : .gray
        }
        
        try? await Task.sleep(for: .seconds(1))
        onComplete()
    }
}

