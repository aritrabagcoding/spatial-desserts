import SwiftUI
import SpriteKit
import SwiftData
import Observation

@MainActor
@Observable
class GameViewModel {
    var subMode: Int = 0
    
    var puzzleProgress: Double = 0.0
    var showSaveToast: Bool = false
    var puzzleScene: PuzzleGameScene?
    
    var reticleColor: Color = .white
    var isSurfaceDetected: Bool = false
    var showLookUpHint: Bool = false
    var showARTutorial: Bool = true
    var showSafetyOverlay: Bool = false
    var isContentPlaced: Bool = false
    var showPlacementWarning: Bool = false
    
    
    var isEditMode: Bool = false
    var selectedPanelName: String? = nil 
    var editHeight: Float = 0.0
    
    var isPanelSelected: Bool { selectedPanelName != nil }
    
    var activeTimerDuration: TimeInterval = 0
    var timerEndDate: Date?
    var isTimerRunning: Bool = false
    var showTimerPicker: Bool = false
    var selectedTimeIndex: Int = 5
    
    func startManualTimer(minutes: Double) {
        let seconds = minutes * 60
        if seconds <= 0 { return }
        activeTimerDuration = seconds
        timerEndDate = Date().addingTimeInterval(seconds)
        isTimerRunning = true
    }
    
    func pauseTimer() {
        if isTimerRunning {
            if let end = timerEndDate {
                activeTimerDuration = max(0, end.timeIntervalSinceNow)
            }
            timerEndDate = nil
            isTimerRunning = false
        }
    }
    
    func resumeTimer() {
        if !isTimerRunning && activeTimerDuration > 0 {
            timerEndDate = Date().addingTimeInterval(activeTimerDuration)
            isTimerRunning = true
        }
    }
    
    func savePuzzle(for recipe: RecipeModel) {
        recipe.puzzleStateJSON = puzzleScene?.save() ?? ""
        if recipe.status == 0 && puzzleProgress > 0 {
            recipe.status = 1
        }
        showSaveToast = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            self.showSaveToast = false
        }
    }
    
    func onPuzzleFinished(recipe: RecipeModel) {
        withAnimation {
            self.subMode = 1
            recipe.status = 2
            recipe.puzzleStateJSON = ""
        }
    }
    
    func getPuzzleScene(for recipe: RecipeModel) -> PuzzleGameScene {
        if let existingScene = puzzleScene { return existingScene }
        let s = PuzzleGameScene()
        s.imgName = recipe.imageName
        s.scaleMode = .resizeFill
        s.savedDat = recipe.puzzleStateJSON
        s.onFin = { [weak self] in
            guard let self = self else { return }
            self.onPuzzleFinished(recipe: recipe)
        }
        s.onUpd = { [weak self] prog in
            self?.puzzleProgress = prog
        }
        puzzleScene = s
        return s
    }
    
    func startARSession() {
        subMode = 2
        showARTutorial = true
        showSafetyOverlay = false
        isContentPlaced = false
        showPlacementWarning = false
        showLookUpHint = false
        
        
        isEditMode = false
        selectedPanelName = nil
        
        AuMgr.shared.pauseBGM()
    }
    
    func exitAR() {
        subMode = 3
        AuMgr.shared.resumeBGM()
    }
    
    func showPlacementAlert() {
        withAnimation { showPlacementWarning = true }
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation { self.showPlacementWarning = false }
        }
    }
}

