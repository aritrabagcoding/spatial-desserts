import SpriteKit

struct PuzzleData: Codable {
    var index: Int; var x: Double; var y: Double; var isLocked: Bool
}

class PuzzlePiece: SKNode {
    var targetPos: CGPoint
    var isLocked: Bool = false
    var shadowNode: SKShapeNode!
    var borderNode: SKShapeNode!
    var contentNode: SKCropNode!
    
    init(img: String, path: CGPath, sz: CGSize, targetPos: CGPoint) {
        self.targetPos = targetPos
        super.init()
        
        shadowNode = SKShapeNode(path: path)
        shadowNode.fillColor = .black; shadowNode.strokeColor = .clear; shadowNode.alpha = 0; shadowNode.position = CGPoint(x: 5, y: -5)
        addChild(shadowNode)
        
        contentNode = SKCropNode()
        let mask = SKShapeNode(path: path); mask.fillColor = .white; mask.lineWidth = 0
        contentNode.maskNode = mask
        
        if let tex = UIImage.safe(img).cgImage {
            let sprite = SKSpriteNode(texture: SKTexture(cgImage: tex))
            sprite.size = sz
            contentNode.addChild(sprite)
        }
        addChild(contentNode)
        
        borderNode = SKShapeNode(path: path); borderNode.fillColor = .clear; borderNode.strokeColor = .white; borderNode.lineWidth = 2
        
        addChild(borderNode)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

