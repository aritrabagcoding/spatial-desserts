import RealityKit
import UIKit

class ARPanelFactory {
    
    static func createQuestPanel(w: Float, h: Float, recipeImage: String) -> ModelEntity {
        let e = createBasePanel(w: w, h: h)
        e.name = AppLogic.EntityNames.questPanel
        
        let imgSize: Float = h * 0.45
        let imgMesh = MeshResource.generatePlane(width: imgSize, height: imgSize, cornerRadius: 0.02)
        var imgMat = UnlitMaterial()
        
        if let tex = try? TextureResource.load(named: recipeImage) {
            imgMat.color = .init(texture: .init(tex))
        } else {
            imgMat.color = .init(tint: .gray)
        }
        
        let imgEnt = ModelEntity(mesh: imgMesh, materials: [imgMat])
        imgEnt.name = AppLogic.EntityNames.dishStamp
        let pad: Float = 0.05
        imgEnt.position = [ (w/2) - (imgSize/2) - pad, (h/2) - (imgSize/2) - pad, 0.006]
        e.addChild(imgEnt)
        
        let btnSize: Float = 0.12
        let btnGap: Float = 0.03 
        let nextX = (w/2) - (btnSize/2) - pad
        let btnY = -(h/2) + (btnSize/2) + pad
        
        let btnNext = createFlatButton(icon: "chevron.right", size: btnSize)
        btnNext.name = AppLogic.EntityNames.btnNext
        btnNext.position = [ nextX, btnY, 0.006]
        e.addChild(btnNext)
        
        let prevX = nextX - btnSize - btnGap
        
        let btnPrev = createFlatButton(icon: "chevron.left", size: btnSize)
        btnPrev.name = AppLogic.EntityNames.btnPrev
        btnPrev.position = [ prevX, btnY, 0.006]
        e.addChild(btnPrev)
        
        return e
    }
    
    static func createTimerPanel(w: Float, h: Float) -> ModelEntity {
        let e = createBasePanel(w: w, h: h)
        e.name = AppLogic.EntityNames.timerPanel
        
        let header = createText(txt: "TIMER", w: 0.2, h: 0.05, color: .white)
        header.position = [0, (h/2) - 0.04, 0.006]
        header.name = AppLogic.EntityNames.timerHeader
        e.addChild(header)
        
        let barW: Float = w * 0.8
        let barH: Float = 0.03
        let bgMesh = MeshResource.generateBox(size: [barW, barH, 0.005], cornerRadius: 0.01)
        var bgMat = UnlitMaterial()
        bgMat.color = .init(tint: .gray.withAlphaComponent(0.5))
        let bg = ModelEntity(mesh: bgMesh, materials: [bgMat])
        bg.position = [0, 0, 0.006]
        bg.name = AppLogic.EntityNames.timerBarBg
        e.addChild(bg)
        
        let fgMesh = MeshResource.generateBox(size: [barW, barH, 0.006], cornerRadius: 0.01)
        var fgMat = UnlitMaterial()
        fgMat.color = .init(tint: .green)
        let fg = ModelEntity(mesh: fgMesh, materials: [fgMat])
        fg.position = [0, 0, 0.007]
        fg.name = AppLogic.EntityNames.timerBarFg
        e.addChild(fg)
        
        return e
    }
    
    static func createIngredientsPanel(w: Float, h: Float) -> ModelEntity {
        let e = createBasePanel(w: w, h: h)
        e.name = AppLogic.EntityNames.ingPanel
        return e
    }
    
    private static func createBasePanel(w: Float, h: Float) -> ModelEntity {
        let m = MeshResource.generateBox(size: [w, h, 0.01], cornerRadius: 0.05)
        var mat = PhysicallyBasedMaterial()
        mat.baseColor = .init(tint: UIColor.white.withAlphaComponent(0.8))
        mat.roughness = 0.2
        mat.metallic = 0.1
        mat.blending = .transparent(opacity: 0.8)
        
        let e = ModelEntity(mesh: m, materials: [mat])
        e.components.set(CollisionComponent(shapes: [ShapeResource.generateBox(size: [w, h, 0.01])]))
        let borderMesh = MeshResource.generateBox(size: [w + 0.002, h + 0.002, 0.008], cornerRadius: 0.05)
        var borderMat = UnlitMaterial()
        borderMat.color = .init(tint: UIColor.white.withAlphaComponent(0.4))
        let borderEnt = ModelEntity(mesh: borderMesh, materials: [borderMat])
        e.addChild(borderEnt)
        return e
    }
    
    private static func createFlatButton(icon: String, size: Float) -> ModelEntity {
        let mesh = MeshResource.generatePlane(width: size, height: size, cornerRadius: size/2)
        
        var mat = UnlitMaterial()
        mat.color = .init(tint: .systemYellow)
        
        let e = ModelEntity(mesh: mesh, materials: [mat])
        e.components.set(CollisionComponent(shapes: [ShapeResource.generateBox(width: size, height: size, depth: 0.01)]))
        
        let iconImg = UIImage(systemName: icon)?.withTintColor(.black, renderingMode: .alwaysOriginal) ?? UIImage()
        
        if let cg = iconImg.cgImage {
            if let tex = try? TextureResource(image: cg, options: .init(semantic: .color)) {
                let iconSize = size * 0.6
                let plane = MeshResource.generatePlane(width: iconSize, height: iconSize)
                var iconMat = UnlitMaterial()
                iconMat.color = .init(texture: .init(tex))
                iconMat.blending = .transparent(opacity: 1.0)
                let iconEnt = ModelEntity(mesh: plane, materials: [iconMat])
                iconEnt.position = [0, 0, 0.002]
                e.addChild(iconEnt)
            }
        }
        return e
    }
    
    static func createText(txt: String, w: Float, h: Float, color: UIColor = .label, scale: Float = 1.0) -> ModelEntity {
        let systemFont = UIFont.systemFont(ofSize: CGFloat(0.035 * scale), weight: .semibold)
        let m = MeshResource.generateText(
            txt,
            extrusionDepth: 0.001,
            font: systemFont,
            containerFrame: CGRect(x: -Double(w)/2, y: -Double(h)/2, width: Double(w), height: Double(h)),
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        let mat = UnlitMaterial(color: color)
        return ModelEntity(mesh: m, materials: [mat])
    }
}

