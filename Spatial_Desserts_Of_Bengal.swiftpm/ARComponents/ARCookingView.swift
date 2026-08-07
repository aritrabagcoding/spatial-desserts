import SwiftUI
import RealityKit
import ARKit

struct ARCookingView: UIViewRepresentable {
    var recipe: RecipeModel
    @Binding var reticleColor: Color
    var onExit: () -> Void
    @Binding var isContentPlaced: Bool
    @Binding var showLookUpHint: Bool
    
    var vm: GameViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        context.coordinator.setup(arView)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.delegate = context.coordinator
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.addSubview(coachingOverlay)
        
        arView.session.run(config)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> ARCoordinator {
        ARCoordinator(p: self)
    }
}

