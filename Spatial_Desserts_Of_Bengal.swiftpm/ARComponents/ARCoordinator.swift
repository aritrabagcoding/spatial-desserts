import Foundation
import RealityKit
import ARKit
import SwiftUI
import Combine
import AudioToolbox

@MainActor
class ARCoordinator: NSObject, ARSessionDelegate, ARCoachingOverlayViewDelegate {
    var parent: ARCookingView
    weak var arView: ARView?
    var gestureHandler: ARGestureHandler?
    
    var rootAnchor: AnchorEntity?
    var questPanel: ModelEntity?
    var timerPanel: ModelEntity?
    var ingPanel: ModelEntity?
    
    weak var selectedEntity: Entity?
    
    var stepIndex: Int = 0
    var hasSpawned: Bool = false {
        didSet { parent.isContentPlaced = hasSpawned }
    }
    
    var updateSubscription: Cancellable?
    var frameCount: Int = 0
    
    let minHeight: Float = 0.3
    let heightRange: Float = 0.5
    
    init(p: ARCookingView) {
        self.parent = p
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReset), name: NSNotification.Name("ResetARSession"), object: nil)
    }
    
    @objc func handleReset() {
        resetARSession()
    }
    
    func setup(_ v: ARView) {
        self.arView = v
        self.gestureHandler = ARGestureHandler(arView: v)
        self.gestureHandler?.coordinator = self
        
        v.session.delegate = self
        self.updateSubscription = v.scene.subscribe(to: SceneEvents.Update.self) { [weak self] e in
            self?.updateLoop(dt: e.deltaTime)
        }
    }
    
    nonisolated func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        MainActor.assumeIsolated { rootAnchor?.isEnabled = false }
    }
    nonisolated func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        MainActor.assumeIsolated { rootAnchor?.isEnabled = true }
    }
    
    func resetARSession() {
        guard let v = arView else { return }
        cleanup()
        hasSpawned = false
        parent.vm.isSurfaceDetected = false
        stepIndex = 0
        AudioServicesPlaySystemSound(1001)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        v.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func selectPanel(_ entity: Entity) {
        self.selectedEntity = entity
        parent.vm.selectedPanelName = entity.name
        
        let currentY = entity.position.y
        let normalized = (currentY - minHeight) / heightRange
        let sliderValue = normalized - 0.5
        parent.vm.editHeight = max(-0.5, min(0.5, sliderValue))
        
        AudioServicesPlaySystemSound(1057)
        pulsePanel(entity)
    }
    
    func updateSelectedPanelAttributes(heightNorm: Float) {
        guard let entity = selectedEntity else { return }
        
        let normalizedInput = heightNorm + 0.5
        let newHeight = minHeight + (normalizedInput * heightRange)
        entity.position.y = newHeight
    }
    
    func onNextButtonTapped() {
        nextStep()
        playFeedback()
    }
    
    func onPrevButtonTapped() {
        prevStep()
        playFeedback()
    }
    
    func attemptSpawn(at point: CGPoint) {
        guard !hasSpawned, let v = arView else { return }
        if let res = v.raycast(from: point, allowing: .estimatedPlane, alignment: .horizontal).first {
            spawnPanels(at: res.worldTransform)
        }
    }
    
    func cleanup() {
        rootAnchor?.removeFromParent()
        questPanel = nil
        timerPanel = nil
        ingPanel = nil
        rootAnchor = nil
        selectedEntity = nil
    }
    
    func spawnPanels(at t: simd_float4x4) {
        guard let v = arView else { return }
        cleanup()
        
        let anchor = AnchorEntity(world: t)
        rootAnchor = anchor
        v.scene.addAnchor(anchor)
        
        questPanel = ARPanelFactory.createQuestPanel(w: 0.8, h: 0.5, recipeImage: parent.recipe.imageName)
        questPanel?.position = [0, minHeight, 0]
        if let qp = questPanel {
            anchor.addChild(qp)
            qp.generateCollisionShapes(recursive: true)
            v.installGestures([.translation, .rotation, .scale], for: qp)
        }
        
        timerPanel = ARPanelFactory.createTimerPanel(w: 0.35, h: 0.25)
        timerPanel?.position = [0.65, minHeight, 0.1]
        timerPanel?.orientation = simd_quatf(angle: Float(-0.4), axis: SIMD3<Float>(0, 1, 0))
        if let tp = timerPanel {
            anchor.addChild(tp)
            tp.generateCollisionShapes(recursive: true)
            v.installGestures([.translation, .rotation, .scale], for: tp)
        }
        
        ingPanel = ARPanelFactory.createIngredientsPanel(w: 0.4, h: 0.5)
        ingPanel?.position = [-0.65, minHeight, 0.1]
        ingPanel?.orientation = simd_quatf(angle: Float(0.4), axis: SIMD3<Float>(0, 1, 0))
        if let ip = ingPanel {
            anchor.addChild(ip)
            ip.generateCollisionShapes(recursive: true)
            v.installGestures([.translation, .rotation, .scale], for: ip)
        }
        
        hasSpawned = true
        parent.reticleColor = .clear
        loadStep()
        loadIngredients()
        playPopUpAnimation()
        
        AudioServicesPlaySystemSound(1057)
    }
    
    func playPopUpAnimation() {
        let panels = [questPanel, timerPanel, ingPanel]
        panels.compactMap{$0}.forEach { entity in
            entity.scale = SIMD3<Float>(0.01, 0.01, 0.01)
            let anim = FromToByAnimation<Transform>(
                from: Transform(scale: .zero, translation: entity.position),
                to: Transform(scale: .one, translation: entity.position),
                duration: 0.6, timing: .easeInOut, bindTarget: .transform
            )
            if let res = try? AnimationResource.generate(with: anim) {
                entity.playAnimation(res)
            }
        }
    }
    
    func updateLoop(dt: TimeInterval) {
        frameCount += 1
        
        if frameCount % 5 == 0 {
            let minScale: Float = 0.6
            let maxScale: Float = 1.5
            [questPanel, timerPanel, ingPanel].compactMap{$0}.forEach { panel in
                if panel.scale.x < minScale {
                    panel.scale = SIMD3<Float>(minScale, minScale, minScale)
                } else if panel.scale.x > maxScale {
                    panel.scale = SIMD3<Float>(maxScale, maxScale, maxScale)
                }
            }
        }
        
        if parent.vm.isEditMode && parent.vm.selectedPanelName != nil {
            updateSelectedPanelAttributes(heightNorm: parent.vm.editHeight)
        }
        
        if frameCount % 10 == 0 {
            if parent.vm.isTimerRunning, let end = parent.vm.timerEndDate, let tp = timerPanel {
                let total = parent.vm.activeTimerDuration
                let remaining = end.timeIntervalSinceNow
                if total > 0 {
                    let progress = max(0, Float(remaining / total))
                    if let bar = tp.children.first(where: { $0.name == AppLogic.EntityNames.timerBarFg }) as? ModelEntity {
                        bar.scale.x = progress
                        var mat = UnlitMaterial()
                        mat.color = .init(tint: progress < 0.2 ? .red : .green)
                        bar.model?.materials = [mat]
                    }
                }
            }
        }
        
        if !hasSpawned && frameCount % 15 == 0 {
            if let v = arView {
                let c = CGPoint(x: v.bounds.midX, y: v.bounds.midY)
                let h = v.raycast(from: c, allowing: .estimatedPlane, alignment: .horizontal)
                DispatchQueue.main.async {
                    self.parent.vm.isSurfaceDetected = !h.isEmpty
                    self.parent.reticleColor = !h.isEmpty ? .green : .white.opacity(0.3)
                }
            }
        }
    }
    
    func nextStep() {
        guard hasSpawned else { return }
        if stepIndex < parent.recipe.steps.count - 1 {
            stepIndex += 1
            loadStep()
            if let qp = questPanel { pulsePanel(qp) }
        }
    }
    
    func prevStep() {
        guard hasSpawned else { return }
        if stepIndex > 0 { stepIndex -= 1; loadStep() }
    }
    
    func pulsePanel(_ entity: Entity) {
        let currentScale = entity.scale
        let pulseScale = currentScale * 1.05
        let up = FromToByAnimation<Transform>(
            from: Transform(scale: currentScale, translation: entity.position),
            to: Transform(scale: pulseScale, translation: entity.position),
            duration: 0.1, timing: .easeInOut, bindTarget: .transform
        )
        let down = FromToByAnimation<Transform>(
            from: Transform(scale: pulseScale, translation: entity.position),
            to: Transform(scale: currentScale, translation: entity.position),
            duration: 0.1, timing: .easeInOut, bindTarget: .transform
        )
        if let resUp = try? AnimationResource.generate(with: up),
           let resDown = try? AnimationResource.generate(with: down) {
            entity.playAnimation(resUp)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                entity.playAnimation(resDown)
            }
        }
    }
    
    func loadStep() {
        guard let qp = questPanel, let tp = timerPanel else { return }
        qp.children.filter { $0.name == AppLogic.EntityNames.stepText }.forEach { $0.removeFromParent() }
        let txt = "STEP \(stepIndex + 1)\n\n" + parent.recipe.steps[stepIndex]
        let tEnt = ARPanelFactory.createText(txt: txt, w: 0.45, h: 0.4, color: .label)
        tEnt.name = AppLogic.EntityNames.stepText;
        tEnt.position = [-0.15, 0, 0.006]
        qp.addChild(tEnt)
        
        tp.children.filter { $0.name == AppLogic.EntityNames.suggText }.forEach { $0.removeFromParent() }
        if stepIndex < parent.recipe.stepTimer.count {
            let val = parent.recipe.stepTimer[stepIndex]
            if val > 0 {
                let m = Int(val / 60)
                let sugg = ARPanelFactory.createText(txt: "Est: \(m) min", w: 0.3, h: 0.1, color: .white)
                sugg.name = AppLogic.EntityNames.suggText
                sugg.position = [0, 0.18, 0.006]
                tp.addChild(sugg)
            }
        }
    }
    
    func loadIngredients() {
        guard let ip = ingPanel else { return }
        let txt = "INVENTORY (\(parent.recipe.yield)):\n\n" + parent.recipe.ingredients.joined(separator: "\n")
        let t = ARPanelFactory.createText(txt: txt, w: 0.35, h: 0.45, color: .label)
        t.position.z = 0.006
        ip.addChild(t)
    }
    
    func playFeedback() {
        AudioServicesPlaySystemSound(1104)
    }
}

