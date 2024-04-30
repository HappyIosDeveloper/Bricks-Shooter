//
//  PhysicalContactExtension.swift
//  Bricks Shooter
//
//  Created by Ahmadreza on 4/30/24.
//  Copyright © 2024 Ahmadreza. All rights reserved.
//

import SpriteKit

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        DispatchQueue.main.async {
            self.actionForContact(contact)
        }
    }
    
    func actionForContact(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if gameState == .isPlaying {
            updateCollisionCount()
            if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BrickCategory {
                actionForContactingBallWithBrick(firstBody, secondBody)
            } else {
                actionForContactingBallWithWall(firstBody, secondBody, contact: contact)
            }
            if soundIsOn {
                playSound(firstBody, secondBody)
            }
        } else {
            actionForContactingOnPause(firstBody, secondBody)
        }
    }
    
    func actionForContactingBallWithWall(_ firstBody:SKPhysicsBody, _ secondBody:SKPhysicsBody, contact: SKPhysicsContact) {
        if (firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory) || (firstBody.categoryBitMask == BottomCategory && secondBody.categoryBitMask == BallCategory) {
            ballHorizontalTrapCount = 0
            if firstBallSavedPosition == nil { // first ball
                firstBallSavedPosition = contact.contactPoint
                firstBallSavedPosition!.y = ballBottomYPosition
                if let ball = firstBody.node as? Ball {
                    ball.stayDown()
                    moveToSavedFirstBallLocation(ball: ball)
                } else {
                    print("something new contacted the wall")
                }
            } else { // second or other balls
                if let ball = firstBody.node as? Ball {
                    if !ball.isDown {
                        ball.stayDown()
                        moveToSavedFirstBallLocation(ball: ball)
                        if numberOfBalls == balls.filter({$0.isDown}).count {
                            allBallsAreDownAction()
                        } else {
                            print("all balls are not down")
                        }
                    } else {
                        print("--- other balls contact | live balls: \(balls.filter({!$0.isDown}).count) | dead balls: \(balls.filter({$0.isDown}).count)) | allBalls: \(numberOfBalls)")
                        if gameState == .isWaitingForTab {
                            print("ha ha got fucking problem")
                        } else {
                            print("check here !? | Game State: \(gameState)")
                        }
                    }
                } else {
                    print("--- its not a ball")
                }
            }
        } else { // something went wrong
            if let ball = firstBody.node as? Ball {
                ballsYPositions.append(ball.position.y)
                if ballsYPositions.count >= balls.filter({!$0.isDown}).count - 1 { // Ball is moving completely horizontal
                    let calculations = ballsYPositions.count - balls.filter({!$0.isDown}).count - ballsYPositions.filter({$0 == ball.position.y}).count
                    if calculations >= 0 || calculations == -balls.filter({!$0.isDown}).count {
                        ballHorizontalTrapCount += 1
                        if ballHorizontalTrapCount > 3 {
                            applyLittleBottomForce(to: ball)
                            if ballHorizontalTrapCount > 7 {
                                print("ball badly stuck!!!")
                                moveToSavedFirstBallLocation(ball: ball)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func actionForContactingBallWithBrick(_ firstBody:SKPhysicsBody, _ secondBody:SKPhysicsBody) {
        //        print("--- actionForContactingBallWithBrick")
        if let brick = secondBody.node as? Brick {
            if numberOfBalls > balls.filter({$0.isDown}).count {
                brickContactAction(for: brick)
            } else {
                print("what happened here? code: 333")
            }
        } else if let bonusBall = secondBody.node as? Ball {
            bonusBallContactAction(for: bonusBall)
        }
        // MARK: uncomment for win
        //        if isGameWon() {
        //            gameState = .isGameOver
        //            gameWon = true
        //        }
    }
    
    func actionForContactingOnPause(_ firstBody:SKPhysicsBody, _ secondBody:SKPhysicsBody) {
        print("--- actionForContactingOnPause")
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory {
            if firstBallSavedPosition != nil {
                if let ball = firstBody.node! as? Ball {
                    moveToSavedFirstBallLocation(ball: ball)
                }
            } else {
                print("gmae is on pause and no ball shooted yet? or one ball is down")
            }
        } else {
            print("ball is contacting bottom on pause")
            createReflectBall(fromPosition: position)
        }
    }
    
    func shootTheBalls() {
        gameState = .isPlaying
        roundCollisionCount = 0
        ballsYPositions.removeAll()
        secondPassedFromShooting = 0
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateGameTimer), userInfo: nil, repeats: true)
        gameTimer?.fire()
    }
    
    func playSound(_ firstBody:SKPhysicsBody, _ secondBody:SKPhysicsBody) {
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BorderCategory {
            run(blipSound)
        }
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == PaddleCategory {
            run(blipPaddleSound)
        }
    }
    
    func applyLittleBottomForce(to ball:Ball) {
        let moveAction = SKAction.applyForce(CGVector(dx: 1, dy: -4), duration: 1)
        ball.run(moveAction)
    }
    
    func applyHeavyBottomForce(to ball:Ball) {
        let moveAction = SKAction.applyForce(CGVector(dx: 0, dy: -40), duration: 1)
        ball.run(moveAction)
    }
    
    func brickContactAction(for brick:Brick) {
        print("--- brickContactAction")
        ballHorizontalTrapCount = 0
        currentScore += 1
        brick.number -= 1
        brick.flash()
        if soundIsOn {
            run(collisionSound)
        }
        if brick.number <= 0 {
            breakBrick(brick)
            if soundIsOn {
                run(breakSound)
            }
        }
        DispatchQueue.main.async {
            self.updateBallEffect()
        }
    }
    
    func bonusBallContactAction(for ball:Ball) {
        if soundIsOn {
            run(collisionSound)
        }
        numberOfBalls += 1
        breakBonusBall(ball)
        addAnotherBallToScene()
    }
    
    func moveToSavedFirstBallLocation(ball: Ball) {
        print("--- moveToSavedFirstBallLocation")
        if let position = firstBallSavedPosition {
            DispatchQueue.main.async {
                if soundIsOn {
                    self.run(self.fastSwoosh)
                }
                let moveAction = SKAction.move(to: position, duration: 0.1)
                ball.position.y = ballBottomYPosition
                ball.run(moveAction)
            }
        } else { // all balls stuck above
            applyLittleBottomForce(to: ball)
        }
    }
    
    func allBallsAreDownAction() {
        print("--- allBallsAreDownAction")
        gameTimer?.invalidate()
        gameTimer = nil
        gameState = .isWaitingForTab
        balls.forEach({$0.isDown = false})
        isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isUserInteractionEnabled = true
            self.setupScene()
        }
    }
    
    func forceJamAllTheBalls() {
        gameTimer?.invalidate()
        gameTimer = nil
        disableBricksForTwoSeconds()
        balls.forEach({applyHeavyBottomForce(to: $0)})
    }
    
    func disableBricksForTwoSeconds() {
        for i in 0..<children.count {
            if children[i].name == BrickCategoryName {
                children[i].physicsBody?.categoryBitMask = BallCategory
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            for i in 0..<self.children.count {
                if self.children[i].name == BrickCategoryName {
                    self.children[i].physicsBody?.categoryBitMask = BrickCategory
                }
            }
        }
    }
    
    func quickWin() {
        gameWon = true
        gameState = .isGameOver
        if let paddle = childNode(withName: PaddleCategoryName) {
            firstBallSavedPosition = paddle.position
        }
        balls.forEach({
            $0.isDown = true
            moveToSavedFirstBallLocation(ball: $0)
        })
    }
    
    func updateCollisionCount() {
        roundCollisionCount += 1
    }
    
    func doubleBallsSpeed() {
        showSppedUpLabel()
        for i in 0..<balls.count {
            balls[i].physicsBody!.velocity = CGVector(dx: balls[i].physicsBody!.velocity.dx * 1.5, dy: balls[i].physicsBody!.velocity.dy * 1.5)
        }
    }
    
    @objc func updateGameTimer() {
        secondPassedFromShooting += 1
        print("secondPassedFromShooting: \(secondPassedFromShooting)")
        if secondPassedFromShooting == 6 {
            doubleBallsSpeed()
        } else if secondPassedFromShooting == 12 {
            doubleBallsSpeed()
        } else if secondPassedFromShooting == 25 {
            doubleBallsSpeed()
        } else if secondPassedFromShooting == 50 {
            doubleBallsSpeed()
        } else if secondPassedFromShooting == 75 {
            doubleBallsSpeed()
        }
    }
    
    func showSppedUpLabel() {
        let label = UILabel(frame: CGRect(x: (view!.frame.width/2)-50, y: 200, width: 100, height: 50))
        label.text = ""
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        view?.addSubview(label)
        DispatchQueue.main.async {
            label.text = "Speed Up!"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            label.removeFromSuperview()
        }
    }
}
