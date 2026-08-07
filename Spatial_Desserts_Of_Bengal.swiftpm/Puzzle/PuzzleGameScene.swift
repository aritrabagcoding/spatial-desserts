import SwiftUI
import SpriteKit

class PuzzleGameScene: SKScene {
    
    var imgName: String = ""
    var onFin: (() -> Void)?
    var onUpd: ((Double) -> Void)?
    var puzzlePieces: [PuzzlePiece] = []
    var draggingCurrentPiece: PuzzlePiece?
    var lastPos: CGPoint = .zero
    var savedDat: String = ""
    
    override func didMove(to view: SKView) {
        let w = self.size.width
        let h = self.size.height
        setupBG(w: w, h: h)
        spawnPieces(w: w, h: h)
        if !savedDat.isEmpty {
            do { try loadData(savedDat) } catch { print("Save Data Corrupt: \(error)") }
        }
        physicsWorld.gravity = .zero
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        let w = self.size.width
        let h = self.size.height
        let newCenter = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        if let bg = self.children.first(where: { $0.zPosition == -100 }) as? SKSpriteNode {
            bg.size = CGSize(width: w, height: h)
            bg.position = newCenter
        }
        if let ghost = self.children.first(where: { $0.zPosition == -5 }) { ghost.position = newCenter }
        
        for piece in puzzlePieces {
            piece.targetPos = newCenter
            if piece.isLocked {
                piece.position = newCenter
            } else {
                let xMin = w * 0.1; let xMax = w * 0.9
                let yMin = h * 0.1; let yMax = h * 0.9
                var newPos = piece.position
                if newPos.x < xMin { newPos.x = xMin }
                if newPos.x > xMax { newPos.x = xMax }
                if newPos.y < yMin { newPos.y = yMin }
                if newPos.y > yMax { newPos.y = yMax }
                piece.position = newPos
            }
        }
    }
    
    func save() -> String {
        let d = puzzlePieces.enumerated().map { PuzzleData(index: $0.0, x: Double($0.1.position.x), y: Double($0.1.position.y), isLocked: $0.1.isLocked) }
        do {
            let cd = try JSONEncoder().encode(d)
            return String(data: cd, encoding: .utf8) ?? ""
        } catch { return "" }
    }
    
    func loadData(_ s: String) throws {
        guard let d = s.data(using: .utf8) else { return }
        let pds = try JSONDecoder().decode([PuzzleData].self, from: d)
        for pd in pds {
            if pd.index >= 0 && pd.index < puzzlePieces.count {
                let p = puzzlePieces[pd.index]
                p.position = CGPoint(x: pd.x, y: pd.y)
                p.isLocked = pd.isLocked
                if p.isLocked { p.position = p.targetPos; p.zPosition = 0 }
            }
        }
        checkProgress()
    }
    
    func setupBG(w: CGFloat, h: CGFloat) {
        let c1 = UIColor(red: 1.0, green: 0.98, blue: 0.86, alpha: 1.0)
        let c2 = UIColor(red: 0.55, green: 0.43, blue: 0.39, alpha: 1.0)
        let tex = createGradientTexture(w: w, h: h, c1: c1, c2: c2)
        let bg = SKSpriteNode(texture: tex)
        bg.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bg.zPosition = -100
        addChild(bg)
    }
    
    func createGradientTexture(w: CGFloat, h: CGFloat, c1: UIColor, c2: UIColor) -> SKTexture {
        let size = CGSize(width: w, height: h)
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            let context = ctx.cgContext
            let colors = [c1.cgColor, c2.cgColor] as CFArray
            let space = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: space, colors: colors, locations: [0, 1]) {
                context.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: h), options: [])
            }
        }
        return SKTexture(image: img)
    }
    
    func spawnPieces(w: CGFloat, h: CGFloat) {
        let pSz = w * GameConfig.puzzlePieceScale
        let sz = CGSize(width: pSz, height: pSz)
        let boardCenter = CGPoint(x: self.frame.midX, y: self.frame.midY)
        let half = pSz / 2
        let pT = CGMutablePath(); pT.move(to: CGPoint(x: -half, y: half)); pT.addLine(to: CGPoint(x: half, y: half)); pT.addLine(to: CGPoint(x: 0, y: 0)); pT.closeSubpath()
        let pR = CGMutablePath(); pR.move(to: CGPoint(x: half, y: half)); pR.addLine(to: CGPoint(x: half, y: -half)); pR.addLine(to: CGPoint(x: 0, y: 0)); pR.closeSubpath()
        let pB = CGMutablePath(); pB.move(to: CGPoint(x: half, y: -half)); pB.addLine(to: CGPoint(x: -half, y: -half)); pB.addLine(to: CGPoint(x: 0, y: 0)); pB.closeSubpath()
        let pL = CGMutablePath(); pL.move(to: CGPoint(x: -half, y: -half)); pL.addLine(to: CGPoint(x: -half, y: half)); pL.addLine(to: CGPoint(x: 0, y: 0)); pL.closeSubpath()
        let paths = [pT, pR, pB, pL]
        
        for path in paths {
            let xMin = w*0.1; let xMax = w*0.9; let yMin = h*0.1; let yMax = h*0.35
            let rx = (xMax > xMin) ? CGFloat.random(in: xMin...xMax) : xMin
            let ry = (yMax > yMin) ? CGFloat.random(in: yMin...yMax) : yMin
            let piece = PuzzlePiece(img: imgName, path: path, sz: sz, targetPos: boardCenter)
            piece.position = CGPoint(x: rx, y: ry)
            addChild(piece)
            puzzlePieces.append(piece)
        }
        
        let ghost = SKShapeNode(rectOf: sz, cornerRadius: 4)
        ghost.strokeColor = UIColor.black.withAlphaComponent(0.8) 
        ghost.lineWidth = 6 
        ghost.fillColor = UIColor.black.withAlphaComponent(0.3)
        ghost.position = boardCenter
        ghost.zPosition = -5
        addChild(ghost)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let loc = t.location(in: self)
        let nodesAtPoint = nodes(at: loc)
        for n in nodesAtPoint {
            if let p = n as? PuzzlePiece ?? n.parent as? PuzzlePiece {
                if !p.isLocked {
                    draggingCurrentPiece = p; lastPos = loc
                    let scUp = SKAction.scale(to: 1.2, duration: 0.1)
                    p.run(scUp); p.shadowNode.alpha = 0.5; p.zPosition = 10
                    return
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let c = draggingCurrentPiece, let t = touches.first else { return }
        let loc = t.location(in: self)
        let dx = loc.x - lastPos.x
        c.zRotation = -dx * 0.002
        c.position = loc; lastPos = loc
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let c = draggingCurrentPiece else { return }
        c.run(SKAction.rotate(toAngle: 0, duration: 0.1))
        c.run(SKAction.scale(to: 1.0, duration: 0.1))
        c.shadowNode.alpha = 0; c.zPosition = 1
        
        if checkSnap(p1: c.position, t1: c.targetPos) {
            c.position = c.targetPos; c.isLocked = true; c.zPosition = 0
            if let path = c.borderNode.path {
                let gl = SKShapeNode(path: path)
                gl.fillColor = .clear; gl.strokeColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
                gl.lineWidth = 4; gl.alpha = 0
                c.addChild(gl)
                gl.run(SKAction.sequence([SKAction.fadeAlpha(to: 1.0, duration: 0.1), SKAction.fadeOut(withDuration: 0.5), SKAction.removeFromParent()]))
            }
            checkProgress()
            if puzzlePieces.allSatisfy({ $0.isLocked }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in self?.onFin?() }
            }
        }
        draggingCurrentPiece = nil
    }
    
    func checkProgress() {
        let cnt = puzzlePieces.filter({ $0.isLocked }).count
        let tot = puzzlePieces.count
        if tot > 0 { onUpd?(Double(cnt) / Double(tot)) }
    }
    
    func checkSnap(p1: CGPoint, t1: CGPoint) -> Bool {
        let d = sqrt(pow(p1.x - t1.x, 2) + pow(p1.y - t1.y, 2))
        return d < self.size.width * GameConfig.snapDistanceRatio
    }
}

