//
//  Brick.swift
//  Bricks Shooter
//
//  Created by Ahmadreza on 4/30/24.
//  Copyright © 2024 Ahmadreza. All rights reserved.
//

import SpriteKit

class Brick: SKSpriteNode {
    
    var label = SKLabelNode()
    var number = 0 {
        didSet {
            updateLabel()
            DispatchQueue.main.async { [self] in
                label.text =  number.description
            }
        }
    }
    
    func updateLabel() {
        label.position.y = -4
        label.zPosition = 1
        label.fontSize = 10
        label.fontColor = .white
        if label.text == nil {
            addChild(label)
        } 
    }
    
    func setup() {
        let textureName = number.toBrickNumber()
        texture = SKTexture(imageNamed: textureName)
        physicsBody!.allowsRotation = false
        physicsBody!.affectedByGravity = false
        physicsBody!.isDynamic = false
        physicsBody!.friction = 0.0
        name = BrickCategoryName
        physicsBody!.categoryBitMask = BrickCategory
        zPosition = 2
        setColor()
    }
    
    func setColor() {
        if Array(0...10).contains(number) {
            color = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        } else if Array(11...20).contains(number) {
            color = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        } else if Array(21...30).contains(number) {
            color = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        } else if Array(31...40).contains(number) {
            color = #colorLiteral(red: 0, green: 0.4094033837, blue: 1, alpha: 1)
        } else if Array(41...50).contains(number) {
            color = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        } else if Array(51...60).contains(number) {
            color = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        } else {
            color = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        }
    }
}

extension SKNode {
    
    func flash() {
        if let node = self as? Brick {
            let changeColorAction: SKAction = SKAction.run { () -> Void in
                node.alpha = 0.5
            }
            let changeBackAction: SKAction = SKAction.run { () -> Void in
                node.alpha = 1
            }
            let waitAction: SKAction = SKAction.wait(forDuration: 0.05)
            let combined: SKAction = SKAction.sequence([changeColorAction, waitAction, changeBackAction])
            run(combined)
        }
    }
}

extension SKScene {
    
    func breakBrick(_ brick: Brick) {
        let particles = SKEmitterNode(fileNamed: "BrokenPlatform")!
        particles.position = brick.position
        particles.zPosition = 3
        particles.particleColorBlendFactor = 1.0
        particles.particleColorSequence = nil
        particles.particleColor = brick.color
        addChild(particles)
        particles.run(SKAction.sequence([SKAction.wait(forDuration: 3.0), SKAction.removeFromParent()]))
        brick.removeFromParent()
    }
}
