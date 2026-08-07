import RealityKit
import UIKit

@MainActor
class ARGestureHandler: NSObject {
    weak var arView: ARView?
    weak var coordinator: ARCoordinator?
    
    init(arView: ARView) {
        self.arView = arView
        super.init()
        setupGestures()
    }
    
    func setupGestures() {
        guard let v = arView else { return }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        v.addGestureRecognizer(tap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        v.addGestureRecognizer(longPress)
    }
    
    @objc func handleTap(_ s: UITapGestureRecognizer) {
        guard let v = arView else { return }
        let loc = s.location(in: v)
        
        if let hit = v.entity(at: loc) {
            if hit.name == AppLogic.EntityNames.btnNext || hit.parent?.name == AppLogic.EntityNames.btnNext {
                coordinator?.onNextButtonTapped()
                return
            }
            if hit.name == AppLogic.EntityNames.btnPrev || hit.parent?.name == AppLogic.EntityNames.btnPrev {
                coordinator?.onPrevButtonTapped()
                return
            }
        } else {
            coordinator?.attemptSpawn(at: loc)
        }
    }
    
    @objc func handleLongPress(_ s: UILongPressGestureRecognizer) {
        guard let v = arView, let coord = coordinator else { return }
        if s.state == .began {
            let loc = s.location(in: v)
            if coord.parent.vm.isEditMode {
                if let hit = v.entity(at: loc) {
                    if let panel = findRootPanel(from: hit) {
                        coord.selectPanel(panel)
                    }
                }
            }
        }
    }
    
    func findRootPanel(from e: Entity) -> Entity? {
        if e.name == AppLogic.EntityNames.questPanel ||
            e.name == AppLogic.EntityNames.timerPanel ||
            e.name == AppLogic.EntityNames.ingPanel {
            return e
        }
        if let p = e.parent { return findRootPanel(from: p) }
        return nil
    }
}

