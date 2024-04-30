//
//  GameOver.swift
//  BreakoutSpriteKitTutorial
//
//  Created by Michael Briscoe on 1/16/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameOver: GKState {
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        if previousState is Playing {
            balls.forEach({
                $0.physicsBody!.collisionBitMask = BorderCategory 
            })
            balls.forEach({$0.physicsBody!.linearDamping = 2})
            scene.physicsWorld.gravity = CGVector(dx: 0, dy: -10.8)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is WaitingForTap.Type
    }
}
