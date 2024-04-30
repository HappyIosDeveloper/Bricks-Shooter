//
//  Ball.swift
//  Bricks Shooter
//
//  Created by Ahmadreza on 4/30/24.
//  Copyright © 2024 Ahmadreza. All rights reserved.
//

import SpriteKit

class Ball: SKSpriteNode {
    
    var id = -1
    var isDown = false
    
    func setResetToDefaultSetting() {
        isDown = false
        size = ballSize
        physicsBody?.isDynamic = true
        physicsBody?.linearDamping = 0
        physicsBody?.affectedByGravity = false
        physicsBody!.categoryBitMask = BallCategory
        physicsBody!.collisionBitMask = BottomCategory | BrickCategory | BorderCategory | PaddleCategory
        physicsBody!.contactTestBitMask = BottomCategory | BrickCategory | BorderCategory | PaddleCategory
    }
    
    func stayDown() {
        print("--- Stay down | ball ID: \(id)")
        isDown = true
        physicsBody?.isDynamic = false
        physicsBody?.linearDamping = 1000
        physicsBody?.affectedByGravity = false
        physicsBody?.velocity = CGVector(dx: 0, dy: 0)
    }
}

extension SKScene {
    
    func breakBonusBall(_ ball: Ball) {
        let particles = SKEmitterNode(fileNamed: "BrokenPlatform")!
        particles.position = ball.position
        particles.zPosition = 3
        particles.particleColorBlendFactor = 1.0
        particles.particleColorSequence = nil
        particles.particleColor = ball.color
        addChild(particles)
        particles.run(SKAction.sequence([SKAction.wait(forDuration: 3.0), SKAction.removeFromParent()]))
        ball.removeFromParent()
    }
}
