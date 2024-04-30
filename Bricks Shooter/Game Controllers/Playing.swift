//
//  Playing.swift
//  BreakoutSpriteKitTutorial
//
//  Created by Michael Briscoe on 1/16/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

class Playing: GKState {
    
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        let ang = angle(between: balls.first!.position, ending: CGPoint(x: guideLine.frame.midX, y: guideLine.frame.midY))
        let force = CGVector(dx:cos(ang) * gameSpeed, dy:sin(ang) * gameSpeed)
        let multiplyValue = 0.8 / Double(balls.count)
        print("force: \(force) | muliply value: \(multiplyValue)")
        if !balls.isEmpty {
            DispatchQueue.main.async { [self] in
                prepareBallsForShooting()
                let now = DispatchTime.now()
                for i in 0..<balls.count {
                    DispatchQueue.main.asyncAfter(deadline: now + Double(i) * multiplyValue) {
                        print("i: \(i)  |  \(Double(i) * 0.1)")
                        balls[i].physicsBody!.applyImpulse(force)
                    }
                }
            }
        }
    }
    
    func prepareBallsForShooting() {
        balls.forEach({$0.physicsBody?.affectedByGravity = false})
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is GameOver.Type
    }
    
    func angle(between starting: CGPoint, ending: CGPoint) -> CGFloat {
        let relativeToStart = CGPoint(x: ending.x - starting.x, y: ending.y - starting.y)
        let radians = atan2(relativeToStart.y, relativeToStart.x)
        let radian = (.pi * 2) + radians
        return radian
    }
}
