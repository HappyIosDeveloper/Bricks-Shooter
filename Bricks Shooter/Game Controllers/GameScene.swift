//
//  GameScene.swift
//  Bricks Shooter
//
//  Created by Ahmadreza on 4/30/24.
//  Copyright © 2024 Ahmadreza. All rights reserved.
//

import SpriteKit
import GameplayKit

let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let BrickCategoryName = "block"
let BonusBallCategoryName = "bonus"
let GameMessageName = "gameMessage"

let BallCategory   : UInt32 = 0x1 << 1
let BottomCategory : UInt32 = 0x10 << 2
let BrickCategory  : UInt32 = 0x100 << 3
let PaddleCategory : UInt32 = 0x1000 << 4
let BorderCategory : UInt32 = 0x10000 << 5
let NotingCategory : UInt32 = 0x100000 << 6
var balls = [Ball]()
var bricks = [Int]()
var firstBallSavedPosition:CGPoint?
var ballCounterLabel = SKLabelNode()
enum GameState { case isPlaying, isGameOver, isWaitingForTab }
var globaleGameState:GameState = .isWaitingForTab
var guideLine = SKShapeNode()
let ballBottomYPosition:CGFloat = 10
var ballHorizontalTrapCount = 0
var roundCollisionCount = 0
var currentScoreLabel = UILabel()
var topScoreLabel = UILabel()
var gameTimer: Timer?
var secondPassedFromShooting = 0
var soundButton = UIButton()
var lastBallEffectUpdate = 0
var ballEffectlevel1 = 100
var ballEffectlevel2 = 200
var ballEffectlevel3 = 400
var ballEffectlevel4 = 800
var ballEffectlevel5 = 1000
var ballsYPositions:[CGFloat] = [] {
    didSet {
        if balls.filter({!$0.isDown}).count <= ballsYPositions.count {
            ballsYPositions.remove(at: 0)
        }
    }
}
var currentScore = 0 {
    didSet {
        currentScoreLabel.text = "Score: \(currentScore)"
        if currentScore > topScore {
            topScore = currentScore
        }
    }
}
var topScore = UserDefaults.standard.integer(forKey: "topScore") {
    didSet {
        topScoreLabel.text = "Top Score: \(topScore)"
        UserDefaults.standard.setValue(topScore, forKey: "topScore")
    }
}

class GameScene: SKScene {
    
    var isFingerOnPaddle = false
    lazy var gmState: GKStateMachine = GKStateMachine(states: [WaitingForTap(scene: self), Playing(scene: self), GameOver(scene: self)])
    var gameState:GameState = .isWaitingForTab {
        didSet {
            print("Game state changed to: \(gameState)")
            globaleGameState = gameState
            switch gameState {
            case .isPlaying:
                gmState = GKStateMachine(states: [WaitingForTap(scene: self), Playing(scene: self), GameOver(scene: self)])
                gmState.enter(Playing.self)
            case .isWaitingForTab: gmState.enter(WaitingForTap.self)
            case .isGameOver: gmState.enter(GameOver.self)
            }
        }
    }
    
    var gameWon : Bool = false {
        didSet {
            if let gameOver = childNode(withName: GameMessageName) as? SKSpriteNode {
                let textureName = gameWon ? "YouWon" : "GameOver"
                let texture = SKTexture(imageNamed: textureName)
                let actionSequence = SKAction.sequence([SKAction.setTexture(texture), SKAction.scale(to: 1.0, duration: 0.25)])
                gameOver.run(actionSequence)
                run(gameWon ? gameWonSound : gameOverSound)
            }
        }
    }
    
    let blipSound = SKAction.playSoundFileNamed("Wood_02", waitForCompletion: false)
    let blipPaddleSound = SKAction.playSoundFileNamed("paddleBlip", waitForCompletion: false)
    let breakSound = SKAction.playSoundFileNamed("Wood_03", waitForCompletion: false)
    let collisionSound = SKAction.playSoundFileNamed("Wood_05", waitForCompletion: false)
    let gameWonSound = SKAction.playSoundFileNamed("game-won", waitForCompletion: false)
    let gameOverSound = SKAction.playSoundFileNamed("game-over", waitForCompletion: false)
    let fireSound = SKAction.playSoundFileNamed("fireSound", waitForCompletion: false)
    let fastSwoosh = SKAction.playSoundFileNamed("Rake Swing Whoosh Close", waitForCompletion: false)
    
    // MARK: - Setup Functions
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        gameWon = false
        createStars()
        addSoundButton()
        setupTopLabels()
        setupScene(isFirstTime: true)
    }
    
    func setupScene(isFirstTime:Bool = false) {
        createBricks()
        setupBorderAndPhysics()
        addBallsToScene()
        firstBallSavedPosition = nil
        if isFirstTime {
            //            setupBallsEffects()
            addBottomBorder()
            createGameMessage()
            view?.showsFPS = true // TODO: Chanhe to false
        }
    }
    
    func getCurrentBricks()-> [SKNode] {
        var currentBricks = [SKNode]()
        for i in 0..<children.count {
            if let name = children[i].name {
                if name == BrickCategoryName {
                    currentBricks.append(children[i])
                }
            }
        }
        return currentBricks
    }
    
    override func update(_ currentTime: TimeInterval) {
        gmState.update(deltaTime: currentTime)
    }
    
    func isGameWon() -> Bool {
        var numberOfBricks = 0
        self.enumerateChildNodes(withName: BrickCategoryName) {
            node, stop in
            numberOfBricks = numberOfBricks + 1
        }
        return numberOfBricks == 0
    }
    
    @objc func soundButtonAction() {
        soundIsOn.toggle()
    }
}

extension SKScene {
    func randomNumber(zeroTo:Int)-> Int {
        return Int.random(in: 1..<zeroTo)
    }
}

// MARK: - Create game elements
extension GameScene {
    
    func setupBorderAndPhysics() {
        let mainFrame = CGRect(origin: .zero, size: CGSize(width: frame.width, height: frame.height - topExtraSpace))
        let borderBody = SKPhysicsBody(edgeLoopFrom: mainFrame)
        borderBody.friction = 0
        borderBody.categoryBitMask = BorderCategory
        physicsBody = borderBody
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        physicsWorld.contactDelegate = self
    }
    
    func addBottomBorder() {
        let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        addChild(bottom)
        bottom.physicsBody!.categoryBitMask = BottomCategory
    }
    
    func createGameMessage() {
        let gameMessage = SKSpriteNode(imageNamed: "TapToPlay")
        gameMessage.name = GameMessageName
        gameMessage.position = CGPoint(x: frame.midX, y: frame.midY)
        gameMessage.zPosition = 4
        gameMessage.setScale(0.0)
        addChild(gameMessage)
    }
    
    func createBricks() {
        currentLevel += 1
        let maximumBrixsInRow = Int(frame.width / (bricksSpace + (bricksSize.width + bricksSpace))) + 1
        let y = (frame.height - bricksSize.height / 2) - topExtraSpace
        let currentBricks = getCurrentBricks()
        let currentBricksNewY = (bricksSize.height + bricksSpace)
        currentBricks.forEach({$0.position.y -= currentBricksNewY})
        for i in 0..<maximumBrixsInRow {
            let number = randomNumber(zeroTo: currentLevel + 3) // TODO chane the number to 3 ~ 5
            let halfBrickSpace = bricksSize.width / 2
            let x = (CGFloat(i+1) * (bricksSize.width + bricksSpace)) - halfBrickSpace
            let brick = Brick(color: .gray, size: bricksSize)
            brick.physicsBody = SKPhysicsBody(rectangleOf: brick.frame.size)
            brick.position = CGPoint(x: x, y: y)
            brick.setup()
            brick.number = number
            if Bool().randomWith(weight: 38) {
                addChild(brick)
                bricks.append(brick.number)
            } else if Bool().randomWith(weight: 10) { // MARK: set bonus balls
                addBonusBallsToScene(position: brick.position)
            }
        }
    }
    
    func addBallsToScene() {
        if let ball = childNode(withName: BallCategoryName) as? Ball {
            ball.id = 0
            ball.setResetToDefaultSetting()
            for i in 0..<numberOfBalls {
                let copy = ball.copy() as! Ball
                copy.isHidden = false
                copy.id = i
                copy.name = BallCategoryName + i.description
                copy.position.y = ballBottomYPosition
                addChild(copy)
                balls.append(copy)
            }
            ball.removeAllActions()
            ball.removeAllChildren()
            ball.removeFromParent()
            ball.run(
                SKAction.sequence([
                    SKAction.removeFromParent()
                ]))
        } else {
            var childrenNames = [String]()
            for i in 0..<children.count {
                if let name = children[i].name {
                    if name.contains(BallCategoryName) {
                        childrenNames.append(name)
                    }
                }
            }
            for i in 0..<childrenNames.count {
                if let ball = childNode(withName: childrenNames[i]) as? Ball {
                    ball.setResetToDefaultSetting()
                }
            }
        }
    }
    
    func addAnotherBallToScene() {
        let ball = balls.first!
        let copy = ball.copy() as! Ball
        copy.isHidden = false
        copy.id = balls.count + 1
        copy.name = BallCategoryName + (balls.count+1).description
        copy.position.y = ballBottomYPosition
        copy.setResetToDefaultSetting()
        addChild(copy)
        balls.append(copy)
        applyHeavyBottomForce(to: ball)
    }
    
    func addBonusBallsToScene(position: CGPoint) {
        if let firstall = balls.first {
            let bonusBall = Ball(color: .gray, size: firstall.size)
            bonusBall.physicsBody = SKPhysicsBody(rectangleOf: bonusBall.frame.size)
            bonusBall.position = position
            bonusBall.physicsBody!.allowsRotation = false
            bonusBall.physicsBody!.affectedByGravity = false
            bonusBall.physicsBody!.isDynamic = false
            bonusBall.physicsBody!.friction = 0.0
            bonusBall.name = BrickCategoryName
            bonusBall.physicsBody!.categoryBitMask = BrickCategory
            bonusBall.zPosition = 2
            bonusBall.texture = SKTexture(imageNamed: "ball")
            bonusBall.size = CGSize(width: bonusBall.size.width, height: bonusBall.size.height)
            addChild(bonusBall)
            // Emitter Effect
            let effectName = "Smoke"
            let trail = SKEmitterNode(fileNamed: effectName)!
            let trailNode = SKNode()
            trailNode.zPosition = 1
            trailNode.name = "ball"
            addChild(trailNode)
            trail.targetNode = trailNode
            bonusBall.addChild(trail)
        }
    }
    
    func setupBallsEffects() {
        for ball in balls {
            let effectName = "BallTrail"
            let trail = SKEmitterNode(fileNamed: effectName)!
            let trailNode = SKNode()
            trailNode.zPosition = 1
            trailNode.name = "ball"
            addChild(trailNode)
            trail.targetNode = trailNode
            ball.addChild(trail)
        }
    }
    
    func updateBallEffect() {
        var effectName = ""
        var needUpdate = false
        var ballColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        if currentScore == ballEffectlevel1 && lastBallEffectUpdate != currentScore {
            needUpdate = true
            ballColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
            effectName = "BallTrail"
            lastBallEffectUpdate = currentScore
        } else if currentScore == ballEffectlevel2 && lastBallEffectUpdate != currentScore {
            needUpdate = true
            ballColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            effectName = "BallTrail2"
            lastBallEffectUpdate = currentScore
        } else if currentScore == ballEffectlevel3 && lastBallEffectUpdate != currentScore {
            needUpdate = true
            ballColor = #colorLiteral(red: 0.3647058904, green: 0.5, blue: 0.9686274529, alpha: 1)
            effectName = "BallTrail3"
            lastBallEffectUpdate = currentScore
        } else if currentScore == ballEffectlevel4 && lastBallEffectUpdate != currentScore {
            needUpdate = true
            ballColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
            effectName = "BallTrail4"
            lastBallEffectUpdate = currentScore
        } else if currentScore == ballEffectlevel5 && lastBallEffectUpdate != currentScore {
            needUpdate = true
            ballColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            effectName = "BallTrail5"
            lastBallEffectUpdate = currentScore
        }
        if needUpdate {
            if soundIsOn {
                run(fireSound)
            }
            for ball in balls {
                let trail = SKEmitterNode(fileNamed: effectName)!
                let trailNode = SKNode()
                trailNode.zPosition = 1
                trailNode.name = "ball"
                ball.colorBlendFactor = 1
                ball.color = ballColor
                addChild(trailNode)
                trail.targetNode = trailNode
                ball.removeAllChildren()
                ball.addChild(trail)
            }
        }
    }
    
    func createStars() {
        let twinklePeriod = 40.0
        let twinkleDuration = 8.5
        let bright = CGFloat(0.5)
        let dim = CGFloat(0.1)
        let numberOfStars = 150
        let brighten = SKAction.fadeAlpha(to: bright, duration: 0.7 * twinkleDuration)
        brighten.timingMode = .easeIn
        let fade = SKAction.fadeAlpha(to: dim, duration: 1 * twinkleDuration)
        fade.timingMode = .easeOut
        let twinkle = SKAction.repeatForever(.sequence([brighten, fade, .wait(forDuration: twinklePeriod - twinkleDuration)]))
        for _ in 0 ..< numberOfStars {
            let star = SKSpriteNode(imageNamed: "glowingDot")
            star.position = CGPoint(x: .random(in: 0 ... UIScreen.main.bounds.width), y: .random(in: 0 ... UIScreen.main.bounds.height))
            let randomSize = Int.random(in: 2 ... 7)
            star.size = CGSize(width: randomSize, height: randomSize)
            star.alpha = dim
            star.speed = .random(in: 0.5 ... 1.5)
            star.run(.sequence([.wait(forDuration: .random(in: 0 ... twinklePeriod)), twinkle]))
            addChild(star)
        }
    }
    
    func setupTopLabels() {
        let yPosition = hasNotch ? 30 : 10
        let xPosition = Int(frame.width) - 170
        let font = UIFont.boldSystemFont(ofSize: 14)
        currentScoreLabel = UILabel(frame: CGRect(x: 10, y: yPosition, width: 100, height: 25))
        currentScoreLabel.font = font
        currentScoreLabel.minimumScaleFactor = 0.1
        currentScoreLabel.textColor = .white
        currentScoreLabel.text = "Score: \(currentScore)"
        view?.addSubview(currentScoreLabel)
        
        topScoreLabel = UILabel(frame: CGRect(x: xPosition, y: yPosition, width: 160, height: 25))
        topScoreLabel.font = font
        topScoreLabel.minimumScaleFactor = 0.1
        topScoreLabel.textAlignment = .right
        topScoreLabel.textColor = .white
        topScoreLabel.text = "Top Score: \(topScore)"
        view?.addSubview(topScoreLabel)
    }
    
    func addSoundButton() {
        let yPosition = hasNotch ? 30 : 10
        let xPosition = Int(frame.width / 2)
        soundButton = UIButton(frame: CGRect(x: xPosition, y: yPosition, width: 20, height: 20))
        soundButton.setImage(soundIsOn ? #imageLiteral(resourceName: "icons8-sound_speaker_filled") : #imageLiteral(resourceName: "icons8-mute"), for: .normal)
        soundButton.tintColor = .white
        soundButton.addTarget(self, action: #selector(soundButtonAction), for: .touchUpInside)
        view?.addSubview(soundButton)
    }
}
