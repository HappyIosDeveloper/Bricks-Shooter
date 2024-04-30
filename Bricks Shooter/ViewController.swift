//
//  ViewController.swift
//  Bricks Shooter
//
//  Created by Ahmadreza on 4/30/24.
//

import UIKit
import SpriteKit

var numberOfBalls = 3
var gameSpeed: CGFloat = 7.0
let bricksSize = CGSize(width: UIScreen.main.bounds.width/13.5, height: UIScreen.main.bounds.width/13.5)
let ballSize = CGSize(width: 10, height: 10)
let bricksSpace:CGFloat = 1
var maximumBreakNumber = 4
var currentLevel = 0
let topExtraSpace:CGFloat = 40
var soundIsOn = UserDefaults.standard.bool(forKey: "soundIsOn") {
    didSet {
        UserDefaults.standard.setValue(soundIsOn, forKey: "soundIsOn")
        soundButton.setImage(soundIsOn ? #imageLiteral(resourceName: "icons8-sound_speaker_filled") : #imageLiteral(resourceName: "icons8-mute"), for: .normal)
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed:"GameScene") {
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            scene.size = UIScreen.main.bounds.size
            if hasNotch {
                scene.size.height -= topExtraSpace
            }
            scene.scaleMode = .aspectFit
            skView.presentScene(scene)
        }
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
