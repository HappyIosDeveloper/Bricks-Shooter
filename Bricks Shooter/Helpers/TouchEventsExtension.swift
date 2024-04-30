//
//  TouchEventsExtension.swift
//  Bricks Shooter
//
//  Created by Ahmadreza on 4/30/24.
//  Copyright © 2024 Ahmadreza. All rights reserved.
//

import SpriteKit

extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == .isPlaying {
            isFingerOnPaddle = false
            forceJamAllTheBalls() // MARK: stop game on tapp
            return
        }
        switch gameState {
        case .isWaitingForTab:
            isFingerOnPaddle = true
            guideLine.isHidden = false
        case .isPlaying:
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            isFingerOnPaddle = true
            if let body = physicsWorld.body(at: touchLocation) {
                if body.node!.name == PaddleCategoryName {
                }
            }
        case .isGameOver:
            let newScene = GameScene(fileNamed:"GameScene")
            newScene!.scaleMode = .aspectFit
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(newScene!, transition: reveal)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFingerOnPaddle {
            if let touch = touches.first {
                let previousLocation = touch.previousLocation(in: self)
                drawGuideLine(toPosition: previousLocation)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFingerOnPaddle {
            shootTheBalls()
        }
        isFingerOnPaddle = false
        guideLine.isHidden = true
    }
    
    func drawGuideLine(toPosition:CGPoint) {
        
        guideLine.removeFromParent()
        let from = CGPoint(x: balls.first!.position.x, y: balls.first!.position.y)
        let linePath = UIBezierPath()
        linePath.move(to: from)
        
        var dx = toPosition.x - from.x
        var dy = toPosition.y - from.y
        let speed:CGFloat = 20
        dx = dx * speed
        dy = dy * speed
        
        var finalX = toPosition.x + dx
        var finalY = toPosition.y + dy
        
        if finalY < 300 {
            finalY = 300
        }
        if finalX < -2400 {
            finalX = -2400
        }
        
        let finalPosition = CGPoint(x: finalX, y: finalY)
        print("final position: \(finalPosition)")
        print("line width: \(linePath.bounds)")
        linePath.addLine(to: finalPosition)
        
        let pattern: [CGFloat] = [5, 5]
        let dashed = SKShapeNode(path: linePath.cgPath.copy(dashingWithPhase: 2, lengths: pattern))

        guideLine = SKShapeNode(path: dashed.path!)
        guideLine.strokeColor = UIColor.white
        guideLine.position = CGPoint(x: balls.first!.centerRect.midX, y:  balls.first!.centerRect.midY)

//      reflect
//        var dx2 = dx * -speed
//        var dy2 = dy * -speed
//        if dx2 > UIScreen.main.bounds.maxX {
//            dx2 = UIScreen.main.bounds.maxX
//        }
//        if dy2 > UIScreen.main.bounds.maxY {
//            dy2 = UIScreen.main.bounds.maxY
//        }
//        let toPosition2:CGPoint = CGPoint(x: dx2, y: dy2)
//        let from2 = finalPosition
//        linePath.addLine(to: toPosition2)
//        linePath.addLine(to: from2)
//        dashed.addChild(SKShapeNode(path: linePath.cgPath.copy(dashingWithPhase: 2, lengths: pattern)))
//        guideLine.addChild(dashed)
//
        addChild(guideLine)
        
        createReflectBall(fromPosition: finalPosition)
    }
    
    func createReflectBall(fromPosition:CGPoint) {
        // this makes clones from balls on the ground
//        let p = UIBezierPath()
//        let hole = UIBezierPath(ovalIn: frame)
//        p.append(hole.reversing())
//        p.usesEvenOddFillRule = true
//        let pattern: [CGFloat] = [5, 5]
//        let dashed = SKShapeNode(path: p.cgPath.copy(dashingWithPhase: 2, lengths: pattern))
//        dashed.addChild(SKShapeNode(path: p.cgPath.copy(dashingWithPhase: 2, lengths: pattern)))
//        guideLine.addChild(dashed)
    }
}
